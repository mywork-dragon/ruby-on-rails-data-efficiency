class IosAppDownloadSnapshot < ActiveRecord::Base

  belongs_to :ios_app
  belongs_to :ios_app_download_snapshot_job
  has_many :ios_app_download_snapshot_exceptions
  
  enum status: [:failure, :success]
  
end
