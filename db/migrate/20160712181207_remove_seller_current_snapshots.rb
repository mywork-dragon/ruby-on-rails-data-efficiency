class RemoveSellerCurrentSnapshots < ActiveRecord::Migration
  def change
    remove_column :ios_app_current_snapshots, :seller
    remove_column :ios_app_current_snapshot_backups, :seller
  end
end
