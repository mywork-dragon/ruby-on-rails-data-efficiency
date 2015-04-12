class IosAppDownloadSnapshotException < ActiveRecord::Base

  belongs_to :ios_app_download_snapshot
  belongs_to :ios_app_download_snapshot_job

end
