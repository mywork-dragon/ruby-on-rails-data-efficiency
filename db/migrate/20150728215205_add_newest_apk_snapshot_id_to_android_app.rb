class AddNewestApkSnapshotIdToAndroidApp < ActiveRecord::Migration
  def change
    add_column :android_apps, :newest_apk_snapshot_id, :integer
    add_index :android_apps, :newest_apk_snapshot_id
  end
end
