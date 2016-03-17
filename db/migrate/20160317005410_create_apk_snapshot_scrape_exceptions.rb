class CreateApkSnapshotScrapeExceptions < ActiveRecord::Migration
  def change
    create_table :apk_snapshot_scrape_exceptions do |t|
      t.integer :apk_snapshot_job_id
      t.text :error
      t.text :backtrace
      t.integer :android_app_id

      t.timestamps
    end
    add_index :apk_snapshot_scrape_exceptions, :apk_snapshot_job_id
    add_index :apk_snapshot_scrape_exceptions, :android_app_id
  end
end
