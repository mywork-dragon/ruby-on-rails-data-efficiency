class CreateAndroidAppSnapshotExceptions < ActiveRecord::Migration
  def change
    create_table :android_app_snapshot_exceptions do |t|
      t.integer :android_app_snapshot_id
      t.text :name
      t.text :backtrace
      t.integer :try

      t.timestamps
    end
    add_index :android_app_snapshot_exceptions, :android_app_snapshot_id
  end
end
