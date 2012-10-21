class FullProfile < ActiveRecord::Base
  attr_accessible :associations, :honors, :interests, :user_id

  belongs_to :user

  has_many :educations
  has_many :positions
end
