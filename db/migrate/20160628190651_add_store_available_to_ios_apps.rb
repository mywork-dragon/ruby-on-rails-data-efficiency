class AddStoreAvailableToIosApps < ActiveRecord::Migration
  def change
    add_column :ios_apps, :app_store_available, :boolean, default: true
    add_index :ios_apps, :app_store_available
  end
end
