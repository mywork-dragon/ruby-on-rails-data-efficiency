class CreateIosAppDownloadSnapshots < ActiveRecord::Migration
  def change
    create_table :ios_app_download_snapshots do |t|
      t.integer :downloads
      t.integer :ios_app_id

      t.timestamps
    end
    add_index :ios_app_download_snapshots, :ios_app_id
  end
end
