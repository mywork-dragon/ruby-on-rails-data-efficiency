class FbAccount < ActiveRecord::Base
  has_many :fb_activities
end
