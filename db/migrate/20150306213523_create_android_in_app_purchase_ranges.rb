class CreateAndroidInAppPurchaseRanges < ActiveRecord::Migration
  def change
    create_table :android_in_app_purchase_ranges do |t|

      t.timestamps
    end
  end
end
