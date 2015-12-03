class AddUniquenessToAndroidSdksApkSnapshot < ActiveRecord::Migration
  def change
    remove_index :android_sdks_apk_snapshots, name: 'index_apk_snapshot_id_android_sdk_id'

    add_index :android_sdks_apk_snapshots, [:apk_snapshot_id, :android_sdk_id], name: 'index_apk_snapshot_id_android_sdk_id', unique: true
  end
end
