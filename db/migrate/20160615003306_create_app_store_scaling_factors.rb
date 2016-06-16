class CreateAppStoreScalingFactors < ActiveRecord::Migration
  def change
    create_table :app_store_scaling_factors do |t|
      t.integer :app_store_id
      t.float :ratings_all_count
      t.float :ratings_per_day_current_release
      t.timestamps null: false
    end

    add_index :app_store_scaling_factors, :app_store_id, unique: true
  end
end
