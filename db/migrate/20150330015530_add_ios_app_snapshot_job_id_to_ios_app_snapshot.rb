class AddIosAppSnapshotJobIdToIosAppSnapshot < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :ios_snapshot_job_id, :integer
    add_index :ios_app_snapshots, :ios_snapshot_job_id
  end
end
