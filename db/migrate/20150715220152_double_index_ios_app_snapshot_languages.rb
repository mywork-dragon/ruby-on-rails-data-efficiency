class DoubleIndexIosAppSnapshotLanguages < ActiveRecord::Migration
  def change
    remove_index :ios_app_snapshots_languages, :ios_app_snapshot_id
    add_index :ios_app_snapshots_languages, [:ios_app_snapshot_id, :ios_app_language_id], name: 'index_ios_app_snapshot_id_language_id'
  end
end
