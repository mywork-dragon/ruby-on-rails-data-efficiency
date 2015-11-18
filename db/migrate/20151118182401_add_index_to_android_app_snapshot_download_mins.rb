class AddIndexToAndroidAppSnapshotDownloadMins < ActiveRecord::Migration
  def change
    add_index :android_app_snapshots, :downloads_min, name: :index_downloads_min
  end
end
