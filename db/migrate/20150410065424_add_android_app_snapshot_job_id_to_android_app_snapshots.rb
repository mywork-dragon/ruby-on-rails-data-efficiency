class AddAndroidAppSnapshotJobIdToAndroidAppSnapshots < ActiveRecord::Migration
  
  def change
    add_column :android_app_snapshots, :android_app_snapshot_job_id, :integer
    add_index :android_app_snapshots, :android_app_snapshot_job_id
  end

end
