class Position < ActiveRecord::Base
  attr_accessible :company, :end_date, :full_profile_id, :is_current, :start_date, :summary, :title

  belongs_to :full_profile
end
