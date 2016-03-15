class AddIndexToAndroidAppIdScanStatusGoodAsOfDateOnApkSnapshots < ActiveRecord::Migration
  def change
    add_index :apk_snapshots, [:android_app_id, :scan_status, :good_as_of_date], name: 'index_android_app_id_scan_status_good_as_of_date'
  end
end
