class CreateIosAppSnapshotsLanguages < ActiveRecord::Migration
  def change
    create_table :ios_app_snapshots_languages do |t|
      t.integer :ios_app_snapshot_id
      t.integer :language_id

      t.timestamps
    end
    add_index :ios_app_snapshots_languages, :ios_app_snapshot_id
    add_index :ios_app_snapshots_languages, :language_id
  end
end
