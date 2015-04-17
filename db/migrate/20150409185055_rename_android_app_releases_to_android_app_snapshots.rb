class RenameAndroidAppReleasesToAndroidAppSnapshots < ActiveRecord::Migration
  def change
    rename_table :android_app_releases, :android_app_snapshots
  end
end
