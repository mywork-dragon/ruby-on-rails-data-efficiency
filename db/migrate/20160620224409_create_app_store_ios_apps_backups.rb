class CreateAppStoreIosAppsBackups < ActiveRecord::Migration
  def change
    create_table :app_store_ios_apps_backups do |t|
      t.integer :ios_app_id
      t.integer :app_store_id
      t.timestamps null: false
    end

    add_index :app_store_ios_apps_backups, [:ios_app_id, :app_store_id], unique: true
    add_index :app_store_ios_apps_backups, :app_store_id
  end
end
