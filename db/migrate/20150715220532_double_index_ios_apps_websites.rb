class DoubleIndexIosAppsWebsites < ActiveRecord::Migration
  def change
    remove_index :ios_apps_websites, :website_id
    remove_index :ios_apps_websites, name: 'index_ios_apps_websites_on_ios_app_id_and_website_id'
    add_index :ios_apps_websites, [:website_id, :ios_app_id], name: 'index_website_id_and_ios_app_id'
  end
end
