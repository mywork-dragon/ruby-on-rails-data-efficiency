class CreateApkSnapshotScrapeFailures < ActiveRecord::Migration
  def change
    create_table :apk_snapshot_scrape_failures do |t|
      t.integer :apk_snapshot_id
      t.integer :android_app_id
      t.integer :reason
      t.text :scrape_content

      t.timestamps
    end
    add_index :apk_snapshot_scrape_failures, :apk_snapshot_id
    add_index :apk_snapshot_scrape_failures, :android_app_id
  end
end
