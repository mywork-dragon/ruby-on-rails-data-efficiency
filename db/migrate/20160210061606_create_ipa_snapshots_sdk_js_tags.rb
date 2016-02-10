class CreateIpaSnapshotsSdkJsTags < ActiveRecord::Migration
  def change
    create_table :ipa_snapshots_sdk_js_tags do |t|
      t.integer :ipa_snapshot_id
      t.integer :sdk_js_tag_id

      t.timestamps
    end

    add_index :ipa_snapshots_sdk_js_tags, [:ipa_snapshot_id, :sdk_js_tag_id], name: 'index_ipa_snapshot_id_sdk_js_tag_id'
    add_index :ipa_snapshots_sdk_js_tags, :sdk_js_tag_id
  end
end
