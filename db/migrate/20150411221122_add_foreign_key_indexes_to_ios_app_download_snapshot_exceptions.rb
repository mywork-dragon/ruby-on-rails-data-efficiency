class AddForeignKeyIndexesToIosAppDownloadSnapshotExceptions < ActiveRecord::Migration
  def change
    
    add_index :ios_app_download_snapshot_exceptions, :ios_app_download_snapshot_id, name: 'index_on_ios_app_download_snapshot_id'
    add_index :ios_app_download_snapshot_exceptions, :ios_app_download_snapshot_job_id, name: 'index_on_ios_app_download_snapshot_job_id'
    
  end
end
