class IndexScalingFactorColumnsOnCurrentSnapshots < ActiveRecord::Migration
  def change
    add_index :ios_app_current_snapshots, [:app_store_id, :ratings_all_count], name: 'index_app_current_store_id_ratings_count'
    add_index :ios_app_current_snapshots, :ratings_all_count, name: 'index_ios_app_current_ratings_count'
    add_index :ios_app_current_snapshots, [:app_store_id, :ratings_per_day_current_release], name: 'index_ios_app_current_store_id_rpd'
    add_index :ios_app_current_snapshots, :ratings_per_day_current_release, name: 'index_ios_app_current_rpd'

    add_index :ios_app_current_snapshot_backups, [:app_store_id, :ratings_all_count], name: 'index_backup_app_current_store_id_ratings_count'
    add_index :ios_app_current_snapshot_backups, :ratings_all_count, name: 'index_backup_ios_app_current_ratings_count'
    add_index :ios_app_current_snapshot_backups, [:app_store_id, :ratings_per_day_current_release], name: 'index_backup_ios_app_current_store_id_rpd'
    add_index :ios_app_current_snapshot_backups, :ratings_per_day_current_release, name: 'index_backup_ios_app_current_rpd'
  end
end
