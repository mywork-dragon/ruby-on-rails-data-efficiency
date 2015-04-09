class DropAndroidInAppPurchaseRanges < ActiveRecord::Migration
  def change
    drop_table :android_in_app_purchase_ranges
  end
end
