class RemoveExtraFieldsFromAppReleases < ActiveRecord::Migration
  def change
    remove_column :android_app_releases, :current_version
    remove_column :android_app_releases, :support_url
    
    remove_column :ios_app_releases, :current_version
  end
end
