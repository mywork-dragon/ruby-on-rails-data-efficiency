class IosFbAdException < ActiveRecord::Base
  belongs_to :ios_fb_ad_job
  belongs_to :ios_device
  belongs_to :fb_account
end
