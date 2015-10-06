class AddAndroidAppSnapshotsScreenshotToAndroidAppSnapshot < ActiveRecord::Migration
  def change
    add_reference :android_app_snapshots, :android_app_snapshots_screenshot, index: true
    create_table :android_app_snapshots_screenshots do |t|
      t.string :url
      t.integer :position
      t.timestamps null: false
    end
  end
end
