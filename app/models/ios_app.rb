class IosApp < ActiveRecord::Base

  has_many :ios_app_releases
  belongs_to :app
  has_many :fb_ad_appearances
    
end
