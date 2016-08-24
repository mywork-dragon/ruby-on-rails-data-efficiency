class AddPriorityToAppStores < ActiveRecord::Migration
  def change
    add_column :app_stores, :priority, :integer
    add_index :app_stores, :priority, unique: true
    add_index :app_stores, [:priority, :enabled]
  end
end
