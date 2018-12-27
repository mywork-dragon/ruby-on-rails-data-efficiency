# == Schema Information
#
# Table name: fb_activity_jobs
#
#  id         :integer          not null, primary key
#  notes      :text(65535)
#  created_at :datetime
#  updated_at :datetime
#

class FbActivityJob < ActiveRecord::Base
  has_many :fb_activities
  has_many :fb_activity_exceptions
end
