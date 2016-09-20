class AddAuditColumnsAndroidAppSnapshots < ActiveRecord::Migration
  def change
    add_timestamps :android_app_snapshots unless AndroidAppSnapshot.column_names.include?('created_at')
    add_timestamps :android_app_snapshot_backups unless AndroidAppSnapshotBackup.column_names.include?('created_at')
  end
end
