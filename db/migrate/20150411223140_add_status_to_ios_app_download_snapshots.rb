class AddStatusToIosAppDownloadSnapshots < ActiveRecord::Migration
  def change
  
    add_column :ios_app_download_snapshots, :status, :integer
    add_index :ios_app_download_snapshots, :status
    
  end
end
 