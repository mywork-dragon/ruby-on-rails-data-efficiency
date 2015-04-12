class AddIosAppDownloadSnapshotJobIdToIosAppDownloadSnapshots < ActiveRecord::Migration
  def change
    
    add_column :ios_app_download_snapshots, :ios_app_download_snapshot_job_id, :integer
    add_index :ios_app_download_snapshots, :ios_app_download_snapshot_job_id, name: 'index_on_ios_app_download_snapshot_job_id'
    
  end
end
