# == Schema Information
#
# Table name: fb_activities
#
#  id                 :integer          not null, primary key
#  fb_activity_job_id :integer
#  fb_account_id      :integer
#  likes              :integer
#  status             :text(65535)
#  duration           :float(24)
#  created_at         :datetime
#  updated_at         :datetime
#

class FbActivity < ActiveRecord::Base
  belongs_to :fb_account
  belongs_to :fb_activity_job
end
