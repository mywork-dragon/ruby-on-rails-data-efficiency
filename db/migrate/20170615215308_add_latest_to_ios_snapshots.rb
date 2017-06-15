class AddLatestToIosSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_current_snapshots, :latest, :boolean, :default => true
    add_column :ios_app_current_snapshots, :last_scraped, :datetime
    add_column :ios_app_current_snapshots, :etag, :string, :limit => 64

    add_column :ios_app_current_snapshot_backups, :latest, :boolean, :default => true
    add_column :ios_app_current_snapshot_backups, :last_scraped, :datetime
    add_column :ios_app_current_snapshot_backups, :etag, :string, :limit => 64

    # Indices migration will be run later, just before we begin inserting multiple snapshots per app. 
    # Writing here to keep record.

    # add_index :ios_app_current_snapshots, [:latest]
    # add_index :ios_app_current_snapshots, [:ios_app_id, :latest]
    # add_index :ios_app_current_snapshots, [:latest, :user_base] # IosSnapshotAccessor.ios_app_ids_from_user_base
    # add_index :ios_app_current_snapshots, [:latest, :app_store_id, :ratings_all_count], :name => 'index_ios_app_current_snapshots_latest_store_ratings' 
    # add_index :ios_app_current_snapshots, [:developer_app_store_identifier, :latest], :name => 'index_ios_app_current_snapshots_on_dev_id_latest'

    # add_index :ios_app_current_snapshot_backups, [:latest]
    # add_index :ios_app_current_snapshot_backups, [:ios_app_id, :latest]
    # add_index :ios_app_current_snapshot_backups, [:latest, :user_base]
    # add_index :ios_app_current_snapshot_backups, [:latest, :app_store_id, :ratings_all_count], :name => 'index_ios_app_current_snapshots_bk_latest_store_ratings' # IosSnapshotAcessor.ios_app_ids_from_store_and_priority
    # add_index :ios_app_current_snapshot_backups, [:developer_app_store_identifier, :latest], :name => 'index_ios_app_current_snapshots_bk_on_dev_id_latest'
  end
end
