class CreateIosAppSnapshotExceptions < ActiveRecord::Migration
  def change
    create_table :ios_app_snapshot_exceptions do |t|
      t.integer :ios_app_snapshot_id
      t.text :name
      t.text :backtrace
      t.integer :try

      t.timestamps
    end
    add_index :ios_app_snapshot_exceptions, :ios_app_snapshot_id
  end
end
