class AddUniquenessToCurrentSnapshotTables < ActiveRecord::Migration
  def change
    add_index :ios_app_current_snapshots, [:ios_app_id, :app_store_id], unique: true, name: 'index_ios_app_current_snap_app_id_store_id'
    add_index :ios_app_current_snapshot_backups, [:ios_app_id, :app_store_id], unique: true, name: 'index_backup_ios_app_current_snap_app_id_store_id'
  end
end
