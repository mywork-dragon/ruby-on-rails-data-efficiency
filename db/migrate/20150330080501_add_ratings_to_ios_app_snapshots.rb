class AddRatingsToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :ratings_current_stars, :decimal
    add_column :ios_app_snapshots, :ratings_current_count, :integer
    add_column :ios_app_snapshots, :ratings_all_stars, :decimal
    add_column :ios_app_snapshots, :ratings_all_count, :integer
  end
end
