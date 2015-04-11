class AddSnapshotJobIdToExceptions < ActiveRecord::Migration
  def change
    
    add_column :android_app_snapshot_exceptions, :android_app_snapshot_job_id, :integer
    add_column :ios_app_snapshot_exceptions, :ios_app_snapshot_job_id, :integer
    
    add_index :android_app_snapshot_exceptions, :android_app_snapshot_job_id, name: 'index_android_app_snapshot_job_id'
    add_index :ios_app_snapshot_exceptions, :ios_app_snapshot_job_id, name: 'index_ios_app_snapshot_job_id'
    
  end
end
