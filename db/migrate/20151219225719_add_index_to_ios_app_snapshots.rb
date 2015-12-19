class AddIndexToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_index :ios_app_snapshots, :ratings_all_count
  end
end
