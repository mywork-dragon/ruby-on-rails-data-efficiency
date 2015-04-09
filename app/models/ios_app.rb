class IosApp < ActiveRecord::Base

  has_many :ios_app_snapshots
  belongs_to :app
  has_many :fb_ad_appearances
  has_many :ios_app_download_snapshots
  
  has_many :ios_app_websites
  has_many :websites, through: :ios_app_websites
end
