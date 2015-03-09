class AndroidAppRelease < ActiveRecord::Base

  has_many :languages
  belongs_to :android_app
  has_one :android_app_download_range
  has_one :android_app_review_snapshot
  
end
