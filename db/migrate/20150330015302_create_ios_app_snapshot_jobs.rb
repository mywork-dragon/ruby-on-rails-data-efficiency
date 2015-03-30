class CreateIosAppSnapshotJobs < ActiveRecord::Migration
  def change
    create_table :ios_app_snapshot_jobs do |t|
      t.text :notes

      t.timestamps
    end
  end
end
