class CreateIosAppSnapshotsScrShts < ActiveRecord::Migration
  def change
    create_table :ios_app_snapshots_scr_shts do |t|
      t.string :url
      t.integer :position
      t.timestamps null: false
    end
    add_reference :ios_app_snapshots_scr_shts, :ios_app_snapshot, index: true
  end
end
