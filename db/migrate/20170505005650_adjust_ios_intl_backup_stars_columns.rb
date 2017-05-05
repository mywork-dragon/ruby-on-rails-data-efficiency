class AdjustIosIntlBackupStarsColumns < ActiveRecord::Migration
  def change
    change_column :ios_app_current_snapshot_backups, :ratings_all_stars, :decimal, precision: 3, scale: 2
    change_column :ios_app_current_snapshot_backups, :ratings_current_stars, :decimal, precision: 3, scale: 2
  end
end
