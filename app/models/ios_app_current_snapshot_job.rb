class IosAppCurrentSnapshotJob < ActiveRecord::Base
  has_many :ios_app_current_snapshots
  has_many :ios_app_current_snapshot_backups
end
