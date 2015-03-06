class CreateIosInAppPurchases < ActiveRecord::Migration
  def change
    create_table :ios_in_app_purchases do |t|

      t.timestamps
    end
  end
end
