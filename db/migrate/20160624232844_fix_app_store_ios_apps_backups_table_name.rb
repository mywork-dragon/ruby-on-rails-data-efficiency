class FixAppStoreIosAppsBackupsTableName < ActiveRecord::Migration
  def change
    rename_table :app_store_ios_apps_backups, :app_stores_ios_app_backups
  end
end
