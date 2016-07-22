class AdjustBackupSnapshotsIndices < ActiveRecord::Migration
  def change
    remove_index :ios_app_current_snapshot_backups, :ios_app_id
    remove_index :ios_app_current_snapshot_backups, :app_store_id
    add_index :ios_app_current_snapshot_backups, :developer_app_store_identifier, name: 'index_current_snapshot_backups_developer_id'

    remove_index :ios_app_current_snapshots, :ios_app_id
    remove_index :ios_app_current_snapshots, :app_store_id
    add_index :ios_app_current_snapshots, :developer_app_store_identifier, name: 'index_current_snapshots_developer_id'
  end
end
