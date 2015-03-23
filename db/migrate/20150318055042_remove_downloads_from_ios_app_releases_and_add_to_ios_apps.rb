class RemoveDownloadsFromIosAppReleasesAndAddToIosApps < ActiveRecord::Migration
  def change
    
    remove_column :ios_app_releases, :downloads
    add_column :ios_apps, :downloads, :integer
    
  end
end
