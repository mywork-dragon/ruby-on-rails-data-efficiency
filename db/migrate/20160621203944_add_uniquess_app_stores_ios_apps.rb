class AddUniquessAppStoresIosApps < ActiveRecord::Migration
  def change
    remove_index :app_stores_ios_apps, [:ios_app_id, :app_store_id]
    add_index :app_stores_ios_apps, [:ios_app_id, :app_store_id], unique: true
  end
end
