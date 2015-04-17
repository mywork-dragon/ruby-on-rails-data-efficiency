class AddNewestAndroidAppSnapshotIdToAndroidApps < ActiveRecord::Migration
  def change
    add_column :android_apps, :newest_android_app_snapshot_id, :integer
    add_index :android_apps, :newest_android_app_snapshot_id
  end
end
