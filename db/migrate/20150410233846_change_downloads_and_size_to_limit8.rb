class ChangeDownloadsAndSizeToLimit8 < ActiveRecord::Migration
  def change
    
    change_column :android_app_snapshots, :installs_min, :integer, limit: 8
    change_column :android_app_snapshots, :installs_max, :integer, limit: 8
    change_column :android_app_snapshots, :size, :integer, limit: 8
    
    change_column :ios_app_download_snapshots, :downloads, :integer, limit: 8
    change_column :ios_app_snapshots, :size, :integer, limit: 8
    
  end
end
