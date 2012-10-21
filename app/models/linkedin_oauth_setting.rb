class LinkedinOauthSetting < ActiveRecord::Base
  attr_accessible :asecret, :atoken, :user_id

  belongs_to :user
end
