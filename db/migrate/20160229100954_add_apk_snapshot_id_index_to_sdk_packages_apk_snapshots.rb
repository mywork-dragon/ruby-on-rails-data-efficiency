class AddApkSnapshotIdIndexToSdkPackagesApkSnapshots < ActiveRecord::Migration
  def change
    add_index :sdk_packages_apk_snapshots, :apk_snapshot_id, name: 'index_apk_snapshot_id'
  end
end
