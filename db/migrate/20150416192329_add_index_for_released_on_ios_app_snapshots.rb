class AddIndexForReleasedOnIosAppSnapshots < ActiveRecord::Migration
  def change
    add_index :ios_app_snapshots, :released
  end
end
