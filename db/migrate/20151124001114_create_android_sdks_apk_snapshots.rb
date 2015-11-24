class CreateAndroidSdksApkSnapshots < ActiveRecord::Migration
  def change
    create_table :android_sdks_apk_snapshots do |t|
      t.integer :android_sdk_id
      t.integer :apk_snapshot_id

      t.timestamps
    end
    add_index :android_sdks_apk_snapshots, [:apk_snapshot_id, :android_sdk_id], name: 'index_apk_snapshot_id_android_sdk_id'
    add_index :android_sdks_apk_snapshots, :android_sdk_id, name: 'android_sdk_id'
  end
end
