class IosAppSnapshotException < ActiveRecord::Base

  belongs_to :ios_app_snapshot
  belongs_to :ios_app_snapshot_job

end
