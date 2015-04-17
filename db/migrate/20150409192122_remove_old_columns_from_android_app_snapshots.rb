class RemoveOldColumnsFromAndroidAppSnapshots < ActiveRecord::Migration
  def change
    remove_column :android_app_snapshots, :category
    remove_column :android_app_snapshots, :link
    remove_column :android_app_snapshots, :previous_release_id
  end
end
