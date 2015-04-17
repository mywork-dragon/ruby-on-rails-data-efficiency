class RenameIosAppReleasesToIosAppSnapshots < ActiveRecord::Migration
  def change
    rename_table :ios_app_releases, :ios_app_snapshots
  end
end
