class IosSnapshotsDiffIndexes < ActiveRecord::Migration
  def change
    remove_index :ios_app_current_snapshots, :name => 'index_ios_app_current_snap_app_id_store_id'
    remove_index :ios_app_current_snapshot_backups, :name => 'index_backup_ios_app_current_snap_app_id_store_id'
    remove_index :ios_app_current_snapshots, :name => 'index_ios_app_current_snapshots_on_user_base'
    remove_index :ios_app_current_snapshot_backups, :name => 'index_ios_app_current_snapshot_backups_on_user_base'
    remove_index :ios_app_current_snapshots, :name => 'index_current_snapshots_developer_id'
    remove_index :ios_app_current_snapshot_backups, :name => 'index_current_snapshot_backups_developer_id'
    remove_index :ios_app_current_snapshots, :name => 'index_app_current_store_id_ratings_count'
    remove_index :ios_app_current_snapshot_backups, :name => 'index_backup_app_current_store_id_ratings_count'

    add_index :ios_app_current_snapshots, [:ios_app_id, :latest] # IosSnapshotAccessor.categories_from_ios_app, IosSnapshotAccessor.user_base_details_from_ios_app, IosSnapshotAccessor.store_and_rating_details_from_ios_app
    add_index :ios_app_current_snapshots, [:ios_app_id, :app_store_id, :latest], unique: true, :name => 'index_ios_app_current_snap_app_id_store_id_latest'
    add_index :ios_app_current_snapshots, [:user_base, :latest] # IosSnapshotAccessor.ios_app_ids_from_user_base
    add_index :ios_app_current_snapshots, [:app_store_id, :ratings_all_count, :latest], :name => 'index_ios_app_current_snapshots_latest_store_ratings' # IosSnapshotAcessor.ios_app_ids_from_store_and_priority
    add_index :ios_app_current_snapshots, [:developer_app_store_identifier, :latest], :name => 'index_ios_app_current_snapshots_on_dev_id_latest' # AppStoreDevelopersWorker.find_developer_app_store_identifier

    add_index :ios_app_current_snapshot_backups, [:ios_app_id, :latest]
    add_index :ios_app_current_snapshot_backups, [:ios_app_id, :app_store_id, :latest], unique: true, :name => 'index_ios_app_current_snap_app_id_store_id_latest_bk'
    add_index :ios_app_current_snapshot_backups, [:user_base, :latest]
    add_index :ios_app_current_snapshot_backups, [:app_store_id, :ratings_all_count, :latest], :name => 'index_ios_app_current_snapshot_backups_latest_store_ratings_bk'
    add_index :ios_app_current_snapshot_backups, [:developer_app_store_identifier, :latest], :name => 'index_ios_app_current_snapshots_on_dev_id_latest_bk'
  end
end
