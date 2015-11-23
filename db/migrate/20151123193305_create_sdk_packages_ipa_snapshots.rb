class CreateSdkPackagesIpaSnapshots < ActiveRecord::Migration
  def change
    create_table :sdk_packages_ipa_snapshots do |t|
      t.integer :sdk_package_id
      t.integer :ipa_snapshot_id
      t.timestamps
    end
    add_index :sdk_packages_ipa_snapshots, [:ipa_snapshot_id, :sdk_package_id], name: 'index_ipa_snapshot_id_sdk_package_id'
    add_index :sdk_packages_ipa_snapshots, :sdk_package_id, name: 'sdk_package_id'
  end
end
