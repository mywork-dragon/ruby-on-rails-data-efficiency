class RemoveAppStoreAvailableFromIosApps < ActiveRecord::Migration
  def change
    remove_column :ios_apps, :app_store_available
  end
end
