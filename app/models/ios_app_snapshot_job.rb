class IosAppSnapshotJob < ActiveRecord::Base

  has_many :ios_app_snapshots
  has_many :ios_app_snapshot_exceptions

end
