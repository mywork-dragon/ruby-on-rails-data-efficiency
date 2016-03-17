class RemoveApkSnapshotIdAndAddApkSnapshotJobIdOnApkSnapshotScrapeFailures < ActiveRecord::Migration
  def change
    remove_column :apk_snapshot_scrape_failures, :apk_snapshot_id
    add_column :apk_snapshot_scrape_failures, :apk_snapshot_job_id, :integer
    add_index :apk_snapshot_scrape_failures, :apk_snapshot_job_id
  end
end
