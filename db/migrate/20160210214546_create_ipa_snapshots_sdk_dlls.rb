class CreateIpaSnapshotsSdkDlls < ActiveRecord::Migration
  def change
    create_table :ipa_snapshots_sdk_dlls do |t|
      t.integer :ipa_snapshot_id
      t.integer :sdk_dll_id

      t.timestamps
    end

    add_index :ipa_snapshots_sdk_dlls, [:ipa_snapshot_id, :sdk_dll_id], name: 'index_ipa_snapshot_id_sdk_dll_id', unique: true
    add_index :ipa_snapshots_sdk_dlls, :sdk_dll_id
  end
end
