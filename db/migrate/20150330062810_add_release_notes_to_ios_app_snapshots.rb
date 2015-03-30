class AddReleaseNotesToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :release_notes, :text
  end
end
