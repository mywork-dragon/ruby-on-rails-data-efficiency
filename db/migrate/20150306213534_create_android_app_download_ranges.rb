class CreateAndroidAppDownloadRanges < ActiveRecord::Migration
  def change
    create_table :android_app_download_ranges do |t|

      t.timestamps
    end
  end
end
