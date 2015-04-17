class AddNewestIosAppSnapshotToIosApps < ActiveRecord::Migration
  def change
    add_column :ios_apps, :newest_ios_app_snapshot_id, :integer
    add_index :ios_apps, :newest_ios_app_snapshot_id
  end
end
