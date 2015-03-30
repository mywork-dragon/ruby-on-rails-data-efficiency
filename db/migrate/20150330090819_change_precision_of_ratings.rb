class ChangePrecisionOfRatings < ActiveRecord::Migration
  def change
    change_column :ios_app_snapshots, :ratings_current_stars, :decimal, precision: 3, scale: 2
  end
end
