class AddIndexToAndroidAppSnapshots < ActiveRecord::Migration
  def change
    add_index :android_app_snapshots, :android_app_id, name: 'index_android_app_id'
    add_index :android_app_snapshots, :android_app_snapshot_job_id, name: 'index_android_app_snapshot_job_id'
    add_index :android_app_snapshots, :released, name: 'index_released'
    add_index :android_app_snapshots, [:android_app_id, :released], name: 'index_android_app_id_and_released'
    add_index :android_app_snapshots, [:android_app_id, :name], name: 'index_android_app_id_and_name'
    add_index :android_app_snapshots, :name, name: 'index_name'
  end
end
