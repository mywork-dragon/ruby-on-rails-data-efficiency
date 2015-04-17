class DestroyAndroidAppDownloadRanges < ActiveRecord::Migration
  def change
    drop_table :android_app_download_ranges
  end
end
