class AddStatusFieldsToApkSnapshotJobs < ActiveRecord::Migration
  def change
    add_column :apk_snapshot_jobs, :ls_lookup_code, :integer
    add_column :apk_snapshot_jobs, :ls_download_code, :integer
  end
end
