class LinkedinController < ApplicationController
  before_filter :authenticate_user!
  
  @@config = { 
      :site => 'https://api.linkedin.com',
      :authorize_path => '/uas/oauth/authenticate',
      :request_token_path => '/uas/oauth/requestToken?scope=r_basicprofile+r_fullprofile',
      :access_token_path => '/uas/oauth/accessToken' 
  }

  def index
    unless LinkedinOauthSetting.find_by_user_id(current_user.id).nil?
      redirect_to "/linkedin_profile"
    end
  end

  def linkedin_profile
    @basic_profile = get_basic_profile
    @full_profile = get_full_profile
    @positions = get_positions
    @educations = get_educations
  end

  def oauth_account
    client = LinkedIn::Client.new('iv6uehul4g5m', 'wtMfG2MbFerSULTC', @@config)
    pin = params[:oauth_verifier]
    if pin
      atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      LinkedinOauthSetting.create!(:asecret => asecret, :atoken => atoken, :user_id => current_user.id)
    end
    redirect_to "/"
  end

  def generate_linkedin_oauth_url
    if LinkedinOauthSetting.find_by_user_id(current_user.id).nil?
      client = LinkedIn::Client.new('iv6uehul4g5m', 'wtMfG2MbFerSULTC', @@config)
      request_token = client.request_token(:oauth_callback => "http://#{request.host}:#{request.port}/oauth_account")
      session[:rtoken] = request_token.token
      session[:rsecret] = request_token.secret
      redirect_to request_token.authorize_url
    else
      redirect_to "/oauth_account"
    end
  end

  private

  def get_client
    linkedin_oauth_setting = LinkedinOauthSetting.find_by_user_id(current_user.id)
    client = LinkedIn::Client.new('iv6uehul4g5m', 'wtMfG2MbFerSULTC', @@config)
    client.authorize_from_access(linkedin_oauth_setting.atoken, linkedin_oauth_setting.asecret)
    client
  end


  def get_basic_profile
    bprofile = BasicProfile.find_by_user_id(current_user.id)
    if bprofile.nil?
      client = get_client
      profile = client.profile(:fields => ["first-name", "last-name", "maiden-name", "formatted-name" ,:headline, :location, :industry, :summary, :specialties, "picture-url", "public-profile-url"])

      basic_profile = profile.to_hash
      basic_profile[:location] = basic_profile["location"]["name"]
      new_basic_profile = BasicProfile.new(basic_profile)
      new_basic_profile.user = current_user
      new_basic_profile.save 
      new_basic_profile
    else
      bprofile
    end
  end

  def get_full_profile
    fprofile = FullProfile.find_by_user_id(current_user.id)
    if fprofile.nil?
      client = get_client
      full_profile = client.profile(:fields => [:associations, :honors, :interests])
      full_profile = full_profile.to_hash
      new_full_profile = FullProfile.new(full_profile)
      new_full_profile.user = current_user
      new_full_profile.save 
      new_full_profile
    else
      fprofile
    end
  end

  def get_positions
    positions = Position.find_all_by_full_profile_id(current_user.full_profile.id)
    if positions.empty?
      client = get_client
      positions = client.profile(:fields => [:positions]).positions.all
      positions.each do |p|
        if p.is_current == "true"
          Position.create(
            title: p.title, 
            summary: p.summary, 
            start_date: Date.parse("1/#{p.start_date.month ? p.start_date.month : 1}/#{p.start_date.year}"), 
            end_date: Date.parse("1/#{p.end_date.month ? p.end_date.month : 1}/#{p.end_date.year}"), 
            is_current: p.is_current, 
            company: p.company.name, 
            full_profile_id: current_user.full_profile.id)
        else
          Position.create(
            title: p.title, 
            summary: p.summary, 
            start_date: Date.parse("1/#{p.start_date.month ? p.start_date.month : 1}/#{p.start_date.year}"), 
            is_current: p.is_current, 
            company: p.company.name, 
            full_profile_id: current_user.full_profile.id)
        end
      end
      current_user.full_profile.positions
    else
      positions
    end
  end


  def get_educations
    educations = Education.find_all_by_full_profile_id(current_user.full_profile.id)
    if educations.empty?
      client = get_client
      educations = client.profile(:fields => [:educations]).educations.all
      educations.each do |e|
        new_educations = Education.create(
          school_name: e.school_name, 
          field_of_study: e.field_of_study, 
          start_date: Date.parse("1/#{e.end_date.month ? p.end_date.month : 1}/#{e.end_date.year}"), 
          end_date: Date.parse("1/#{e.end_date.month ? p.end_date.month : 1}/#{e.end_date.year}"), 
          degree: e.degree, 
          activities: e.activities, 
          notes: e.notes, 
          full_profile_id: current_user.full_profile.id)  
      end
      current_user.full_profile.educations
    else
      educations
    end
  end

end
