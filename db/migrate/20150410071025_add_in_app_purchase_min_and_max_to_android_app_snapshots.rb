class AddInAppPurchaseMinAndMaxToAndroidAppSnapshots < ActiveRecord::Migration
  def change
    
    add_column :android_app_snapshots, :in_app_purchase_min, :integer
    add_column :android_app_snapshots, :in_app_purchase_max, :integer
    
  end
end
