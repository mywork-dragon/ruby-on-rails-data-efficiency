class AddEnabledToAppStores < ActiveRecord::Migration
  def change
    add_column :app_stores, :enabled, :boolean
    add_index :app_stores, :enabled
  end
end
