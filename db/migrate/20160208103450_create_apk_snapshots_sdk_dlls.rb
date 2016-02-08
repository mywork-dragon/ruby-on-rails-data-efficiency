class CreateApkSnapshotsSdkDlls < ActiveRecord::Migration
  def change
    create_table :apk_snapshots_sdk_dlls do |t|
      t.integer :apk_snapshot_id
      t.integer :sdk_dll_id

      t.timestamps
    end

    add_index :apk_snapshots_sdk_dlls, [:apk_snapshot_id, :sdk_dll_id], name: 'index_apk_snapshot_id_sdk_dll_id'
    add_index :apk_snapshots_sdk_dlls, :sdk_dll_id, name: 'index_sdk_dll_id'
  end
end
