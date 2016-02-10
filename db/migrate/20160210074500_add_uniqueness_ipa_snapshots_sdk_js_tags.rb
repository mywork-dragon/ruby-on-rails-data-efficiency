class AddUniquenessIpaSnapshotsSdkJsTags < ActiveRecord::Migration
  def change
    remove_index :ipa_snapshots_sdk_js_tags, name: 'index_ipa_snapshot_id_sdk_js_tag_id'

    add_index :ipa_snapshots_sdk_js_tags, [:ipa_snapshot_id, :sdk_js_tag_id], name: 'index_ipa_snapshot_id_sdk_js_tag_id', unique: true
  end
end
