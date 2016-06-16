class ChangeIntegerSizeOnIosAppCurrentSnapshotBackups < ActiveRecord::Migration
  def change
    change_column :ios_app_current_snapshot_backups, :size, :integer, limit: 8
  end
end
