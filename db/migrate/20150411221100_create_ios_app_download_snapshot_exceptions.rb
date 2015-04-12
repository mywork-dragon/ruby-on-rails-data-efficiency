class CreateIosAppDownloadSnapshotExceptions < ActiveRecord::Migration
  def change
    create_table :ios_app_download_snapshot_exceptions do |t|
      t.integer :ios_app_download_snapshot_id
      t.text :name
      t.text :backtrace
      t.integer :try
      t.integer :ios_app_download_snapshot_job_id

      t.timestamps
    end
  end
end
