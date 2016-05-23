class CreateIosAppCurrentSnapshotJobs < ActiveRecord::Migration
  def change
    create_table :ios_app_current_snapshot_jobs do |t|
      t.text :notes

      t.timestamps null: false
    end
  end
end
