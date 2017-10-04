class DropAndroidAppSnapshotBackups < ActiveRecord::Migration
  def change
    drop_table :android_app_snapshot_backups
  end
end
