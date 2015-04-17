class RenameIosAppWebsitesToIosAppsWebsites < ActiveRecord::Migration
  def change
    rename_table :ios_app_websites, :ios_apps_websites
  end
end
