class AddScanVersionToApkSnapshots < ActiveRecord::Migration
  def change
    add_column :apk_snapshots, :scan_version, :integer
    add_index :apk_snapshots, :scan_version
  end
end
