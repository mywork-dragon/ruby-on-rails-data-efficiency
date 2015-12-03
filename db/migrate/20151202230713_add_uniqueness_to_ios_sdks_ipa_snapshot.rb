class AddUniquenessToIosSdksIpaSnapshot < ActiveRecord::Migration
  def change
    remove_index :ios_sdks_ipa_snapshots, name: 'index_ipa_snapshot_id_ios_sdk_id'

    add_index :ios_sdks_ipa_snapshots, [:ipa_snapshot_id, :ios_sdk_id], name: 'index_ipa_snapshot_id_ios_sdk_id', unique: true
  end
end
