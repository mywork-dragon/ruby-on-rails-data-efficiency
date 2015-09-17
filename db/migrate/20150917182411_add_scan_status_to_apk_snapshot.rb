class AddScanStatusToApkSnapshot < ActiveRecord::Migration
  def change
  	add_column :apk_snapshots, :scan_status, :integer
  	add_index :apk_snapshots, :scan_status
  end
end
