# == Schema Information
#
# Table name: ios_fb_ad_exceptions
#
#  id               :integer          not null, primary key
#  ios_fb_ad_job_id :integer
#  fb_account_id    :integer
#  ios_device_id    :integer
#  error            :text(65535)
#  backtrace        :text(65535)
#  created_at       :datetime
#  updated_at       :datetime
#

class IosFbAdException < ActiveRecord::Base
  belongs_to :ios_fb_ad_job
  belongs_to :ios_device
  belongs_to :fb_account
end
