# == Schema Information
#
# Table name: ios_fb_ad_jobs
#
#  id         :integer          not null, primary key
#  notes      :text(65535)
#  created_at :datetime
#  updated_at :datetime
#  job_type   :integer
#

class IosFbAdJob < ActiveRecord::Base
  has_many :ios_fb_ads
  has_many :ios_fb_ad_exceptions

  has_many :ios_fb_ad_processing_exceptions, through: :ios_fb_ads

  enum job_type: [:scrape, :clean]

end
