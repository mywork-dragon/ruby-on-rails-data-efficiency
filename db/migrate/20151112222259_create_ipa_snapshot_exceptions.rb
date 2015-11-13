class CreateIpaSnapshotExceptions < ActiveRecord::Migration
  def change
    create_table :ipa_snapshot_exceptions do |t|
      t.integer :ipa_snapshot_id
      t.integer :ipa_snapshot_job_id
      t.integer :error_code
      t.text :error
      t.text :backtrace

      t.timestamps
    end
  end
end
