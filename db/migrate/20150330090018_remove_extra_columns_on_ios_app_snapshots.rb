class RemoveExtraColumnsOnIosAppSnapshots < ActiveRecord::Migration
  def change
    remove_column :ios_app_snapshots, :category
    remove_column :ios_app_snapshots, :updated
    remove_column :ios_app_snapshots, :link
    remove_column :ios_app_snapshots, :previous_release_id
    remove_column :ios_app_snapshots, :in_app_purchases
  end
end
