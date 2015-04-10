class AddInstallsMinAndMaxToAndroidAppSnapshots < ActiveRecord::Migration
  def change
    
    add_column :android_app_snapshots, :installs_min, :integer
    add_column :android_app_snapshots, :installs_max, :integer
    
  end
end
