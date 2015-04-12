class AddRatingsPerDayCurrentToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :ratings_per_day_current_release, :decimal, precision: 10, scale: 2
  end
end
