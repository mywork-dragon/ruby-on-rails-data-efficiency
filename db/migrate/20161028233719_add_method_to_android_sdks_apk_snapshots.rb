class AddMethodToAndroidSdksApkSnapshots < ActiveRecord::Migration
  def change
    add_column :android_sdks_apk_snapshots, :method, :integer
    add_index :android_sdks_apk_snapshots, [:apk_snapshot_id, :android_sdk_id, :method], unique: true, name: 'index_apk_snapshot_id_sdk_id_method'
    remove_index :android_sdks_apk_snapshots, name: 'index_apk_snapshot_id_android_sdk_id'
  end
end
