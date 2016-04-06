class IosFbAdJob < ActiveRecord::Base
  has_many :ios_fb_ads
  has_many :ios_fb_ad_exceptions

  has_many :ios_fb_ad_processing_exceptions, through: :ios_fb_ads

  enum job_type: [:scrape, :clean]

end
