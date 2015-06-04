class CreateApkSnapshotJobs < ActiveRecord::Migration
  def change
    create_table :apk_snapshot_jobs do |t|
      t.text :notes
      t.boolean :is_fucked

      t.timestamps
    end
  end
end
