class AddMethodToIosSdksIpaSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_sdks_ipa_snapshots, :method, :integer
    remove_index :ios_sdks_ipa_snapshots, name: 'index_ipa_snapshot_id_ios_sdk_id'

    add_index :ios_sdks_ipa_snapshots, [:ipa_snapshot_id, :ios_sdk_id, :method], name: 'index_ipa_snapshot_id_ios_sdk_id_method', unique: true
  end
end
