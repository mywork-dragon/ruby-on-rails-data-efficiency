class CreateAppStoreScalingFactorBackups < ActiveRecord::Migration
  def change
    create_table :app_store_scaling_factor_backups do |t|
      t.integer :app_store_id
      t.float :ratings_all_count
      t.float :ratings_per_day_current_release
      t.timestamps null: false
    end

    add_index :app_store_scaling_factor_backups, :app_store_id, unique: true
  end
end
