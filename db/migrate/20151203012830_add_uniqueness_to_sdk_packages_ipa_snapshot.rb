class AddUniquenessToSdkPackagesIpaSnapshot < ActiveRecord::Migration
  def change
    remove_index :sdk_packages_ipa_snapshots, name: 'index_ipa_snapshot_id_sdk_package_id'

    add_index :sdk_packages_ipa_snapshots, [:sdk_package_id, :ipa_snapshot_id], name: 'index_sdk_package_id_ipa_snapshot_id', unique: true
  end
end
