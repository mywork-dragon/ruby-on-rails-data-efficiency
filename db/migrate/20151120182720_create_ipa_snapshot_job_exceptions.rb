class CreateIpaSnapshotJobExceptions < ActiveRecord::Migration
  def change
    create_table :ipa_snapshot_job_exceptions do |t|
      t.integer :ipa_snapshot_job_id
      t.text :error
      t.text :backtrace
      t.timestamps
    end

    add_index :ipa_snapshot_job_exceptions, :ipa_snapshot_job_id
  end
end
