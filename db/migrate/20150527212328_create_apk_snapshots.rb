class CreateApkSnapshots < ActiveRecord::Migration
  def change
    create_table :apk_snapshots do |t|
      t.text :version
      t.integer :google_accounts_id
      t.integer :android_app_id
      t.float :download_time
      t.float :unpack_time
      t.integer :status
      t.integer :apk_snapshot_job_id

      t.timestamps
    end
    add_index :apk_snapshots, :google_accounts_id
    add_index :apk_snapshots, :android_app_id
  end

end
