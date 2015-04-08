class RenameIosAppReleaseIdToIosSnapshotIdInIosInAppPurchases < ActiveRecord::Migration
  def change
    rename_column :ios_in_app_purchases, :ios_app_release_id, :ios_app_snapshot_id
  end
end
