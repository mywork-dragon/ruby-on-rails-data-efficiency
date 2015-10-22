class CreateAndroidAppSnapshotsScrShts < ActiveRecord::Migration
  def change
    create_table :android_app_snapshots_scr_shts do |t|
      t.string :url
      t.integer :position
      t.timestamps null: false
    end
    add_reference :android_app_snapshots_scr_shts, :android_app_snapshot, index: true
  end
end
