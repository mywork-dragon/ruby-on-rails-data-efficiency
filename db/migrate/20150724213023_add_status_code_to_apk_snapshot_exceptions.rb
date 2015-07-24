class AddStatusCodeToApkSnapshotExceptions < ActiveRecord::Migration
  def change
  	add_column :apk_snapshot_exceptions, :status_code, :integer
  	add_index :apk_snapshot_exceptions, :status_code, name: 'index_apk_status_code'
  end
end