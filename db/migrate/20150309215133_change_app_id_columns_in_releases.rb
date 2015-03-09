class ChangeAppIdColumnsInReleases < ActiveRecord::Migration
  def change
    
    rename_column :android_app_releases, :app_id, :android_app_id
    rename_column :ios_app_releases, :app_id, :ios_app_id
    
  end
end
