class ChangeInstallsToDownloadsInAndroidAppSnapshots < ActiveRecord::Migration
  def change
    
    rename_column :android_app_snapshots, :installs_min, :downloads_min
    rename_column :android_app_snapshots, :installs_max, :downloads_max
    
  end
end
