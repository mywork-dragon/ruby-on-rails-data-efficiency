class IosAppDownloadSnapshotJob < ActiveRecord::Base

  has_many :ios_app_download_snapshots
  has_many :ios_app_download_snapshot_exceptions

end
