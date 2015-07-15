class DoubleIndexAndroidAppsWebsites < ActiveRecord::Migration
  def change
    remove_index :android_apps_websites, :website_id
    add_index :android_apps_websites, [:website_id, :android_app_id]
  end
end
