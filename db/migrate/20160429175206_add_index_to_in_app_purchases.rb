class AddIndexToInAppPurchases < ActiveRecord::Migration
  def change
    add_index :ios_in_app_purchases, :ios_app_snapshot_id
  end
end
