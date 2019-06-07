class RemoveCurrentSnapshotBackupTables < ActiveRecord::Migration
  def up
    drop_table :ios_app_categories_current_snapshot_backups
    drop_table :ios_app_current_snapshot_backups
  end
  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
