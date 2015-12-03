class AddUniquenessToSdkPackagesApkSnapshot < ActiveRecord::Migration
  def change
    remove_index :sdk_packages_apk_snapshots, name: 'index_apk_snapshot_id_sdk_package_id'

    add_index :sdk_packages_apk_snapshots, [:sdk_package_id, :apk_snapshot_id], name: 'index_sdk_package_id_apk_snapshot_id', unique: true
  end
end
