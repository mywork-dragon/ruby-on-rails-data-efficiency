class CreateIosSdksIpaSnapshots < ActiveRecord::Migration
  def change
    create_table :ios_sdks_ipa_snapshots do |t|
      t.integer :ios_sdk_id
      t.integer :ipa_snapshot_id

      t.timestamps
    end
    add_index :ios_sdks_ipa_snapshots, [:ipa_snapshot_id, :ios_sdk_id], name: 'index_ipa_snapshot_id_ios_sdk_id'
    add_index :ios_sdks_ipa_snapshots, :ios_sdk_id, name: 'ios_sdk_id'
  end
end
