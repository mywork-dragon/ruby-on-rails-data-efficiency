class AddVersionToApkSnapshotScrapeFailures < ActiveRecord::Migration
  def change
    add_column :apk_snapshot_scrape_failures, :version, :string
  end
end
