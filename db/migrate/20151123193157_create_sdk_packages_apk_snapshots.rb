class CreateSdkPackagesApkSnapshots < ActiveRecord::Migration
  def change
    create_table :sdk_packages_apk_snapshots do |t|
      t.integer :sdk_package_id
      t.integer :apk_snapshot_id
      t.timestamps
    end
    add_index :sdk_packages_apk_snapshots, [:apk_snapshot_id, :sdk_package_id], name: 'index_apk_snapshot_id_sdk_package_id'
    add_index :sdk_packages_apk_snapshots, :sdk_package_id, name: 'sdk_package_id'
  end
end
