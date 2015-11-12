class CreateIpaSnapshotJobs < ActiveRecord::Migration
  def change
    create_table :ipa_snapshot_jobs do |t|
      t.integer :job_type
      t.boolean :complete
      t.text :notes
      
      t.timestamps
    end
  end
end
