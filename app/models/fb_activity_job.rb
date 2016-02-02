class FbActivityJob < ActiveRecord::Base
  has_many :fb_activities
  has_many :fb_activity_exceptions
end
