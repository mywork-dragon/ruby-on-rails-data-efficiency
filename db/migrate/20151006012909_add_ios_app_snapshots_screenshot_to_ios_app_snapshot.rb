class AddIosAppSnapshotsScreenshotToIosAppSnapshot < ActiveRecord::Migration
  def change
    add_reference :ios_app_snapshots, :ios_app_snapshots_screenshot, index: true
    create_table :ios_app_snapshots_screenshots do |t|
      t.string :url
      t.integer :position
      t.timestamps null: false
    end
  end
end
