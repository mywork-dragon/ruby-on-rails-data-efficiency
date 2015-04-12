class CreateIosAppDownloadSnapshotJobs < ActiveRecord::Migration
  def change
    create_table :ios_app_download_snapshot_jobs do |t|
      t.string :notes

      t.timestamps
    end
  end
end
