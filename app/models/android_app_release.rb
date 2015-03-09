class AndroidAppRelease < ActiveRecord::Base

  has_many :languages
  belongs_to :app
  belongs_to :ios_app_release
  has_one :android_app_download_range
  has_one :android_app_review_snapshot
  
end
