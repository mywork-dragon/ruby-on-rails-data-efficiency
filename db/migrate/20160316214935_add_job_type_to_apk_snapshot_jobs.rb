class AddJobTypeToApkSnapshotJobs < ActiveRecord::Migration
  def change
    add_column :apk_snapshot_jobs, :job_type, :integer
    add_index :apk_snapshot_jobs, :job_type
  end
end
