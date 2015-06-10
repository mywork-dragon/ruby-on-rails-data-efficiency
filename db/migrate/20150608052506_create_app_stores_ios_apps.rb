class CreateAppStoresIosApps < ActiveRecord::Migration
  def change
    create_table :app_stores_ios_apps do |t|
      t.integer :app_store_id
      t.integer :ios_app_id

      t.timestamps
    end
    add_index :app_stores_ios_apps, :app_store_id
    add_index :app_stores_ios_apps, :ios_app_id
  end
end
