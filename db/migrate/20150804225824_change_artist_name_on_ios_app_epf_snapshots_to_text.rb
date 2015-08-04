class ChangeArtistNameOnIosAppEpfSnapshotsToText < ActiveRecord::Migration
  def change
    remove_index :ios_app_epf_snapshots, :artist_name
    change_column :ios_app_epf_snapshots, :artist_name, :text
  end
end
