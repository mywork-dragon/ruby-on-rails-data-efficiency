class CreateAndroidAppSnapshotJobs < ActiveRecord::Migration
  def change
    create_table :android_app_snapshot_jobs do |t|
      t.text :notes

      t.timestamps
    end
  end
end
