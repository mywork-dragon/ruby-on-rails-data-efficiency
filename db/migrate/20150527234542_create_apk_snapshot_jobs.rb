class CreateApkSnapshotJobs < ActiveRecord::Migration
  def change
    create_table :apk_snapshot_jobs do |t|
      t.text :notes
      t.boolean :is_fucked
      t.integer :quit_on_exception_id

      t.timestamps
    end
  end
end
