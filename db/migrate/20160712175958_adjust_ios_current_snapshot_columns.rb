class AdjustIosCurrentSnapshotColumns < ActiveRecord::Migration
  def change
    remove_column :ios_app_current_snapshots, :support_url
    remove_column :ios_app_current_snapshots, :seller_url_text
    remove_column :ios_app_current_snapshots, :support_url_text
    remove_column :ios_app_current_snapshots, :copyright
    remove_column :ios_app_current_snapshots, :editors_choice
    remove_column :ios_app_current_snapshots, :status
    remove_column :ios_app_current_snapshots, :by

    add_column :ios_app_current_snapshots, :app_link_urls, :text
    add_column :ios_app_current_snapshots, :has_in_app_purchases, :boolean
    add_column :ios_app_current_snapshots, :seller_name, :text


    remove_column :ios_app_current_snapshot_backups, :support_url
    remove_column :ios_app_current_snapshot_backups, :seller_url_text
    remove_column :ios_app_current_snapshot_backups, :support_url_text
    remove_column :ios_app_current_snapshot_backups, :copyright
    remove_column :ios_app_current_snapshot_backups, :editors_choice
    remove_column :ios_app_current_snapshot_backups, :status
    remove_column :ios_app_current_snapshot_backups, :by

    add_column :ios_app_current_snapshot_backups, :app_link_urls, :text
    add_column :ios_app_current_snapshot_backups, :has_in_app_purchases, :boolean
    add_column :ios_app_current_snapshot_backups, :seller_name, :text
  end
end
