class ChangeItunesReleaseDateOnIosAppEpfSnapshotsToDate < ActiveRecord::Migration
  def change
    change_column :ios_app_epf_snapshots, :itunes_release_date, :date
  end
end
