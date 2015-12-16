class CreateIpaSnapshotLookupFailures < ActiveRecord::Migration
  def change
    create_table :ipa_snapshot_lookup_failures do |t|
      t.integer :ipa_snapshot_job_id
      t.integer :ios_app_id
      t.integer :reason
      t.text :lookup_content
      t.timestamps
    end
    add_index :ipa_snapshot_lookup_failures, :ipa_snapshot_job_id
    add_index :ipa_snapshot_lookup_failures, :ios_app_id
  end
end
