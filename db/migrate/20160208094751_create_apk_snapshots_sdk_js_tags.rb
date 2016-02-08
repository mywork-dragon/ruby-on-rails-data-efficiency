class CreateApkSnapshotsSdkJsTags < ActiveRecord::Migration
  def change
    create_table :apk_snapshots_sdk_js_tags do |t|
      t.integer :apk_snapshot_id
      t.integer :sdk_js_tag_id

      t.timestamps
    end

    add_index :apk_snapshots_sdk_js_tags, [:apk_snapshot_id, :sdk_js_tag_id], name: 'index_apk_snapshot_id_sdk_js_tag_id'
    add_index :apk_snapshots_sdk_js_tags, :sdk_js_tag_id, name: 'index_sdk_js_tag_id'
  end
end
