class ChangePrecisionOfRatingsAll < ActiveRecord::Migration
  def change
    change_column :ios_app_snapshots, :ratings_all_stars, :decimal, precision: 3, scale: 2
  end
end
