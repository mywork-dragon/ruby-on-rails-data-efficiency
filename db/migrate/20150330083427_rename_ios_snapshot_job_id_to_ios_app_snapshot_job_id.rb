class RenameIosSnapshotJobIdToIosAppSnapshotJobId < ActiveRecord::Migration
  def change
    rename_column :ios_app_snapshots, :ios_snapshot_job_id, :ios_app_snapshot_job_id
  end
end
