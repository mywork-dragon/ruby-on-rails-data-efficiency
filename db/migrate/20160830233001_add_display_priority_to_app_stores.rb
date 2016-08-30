class AddDisplayPriorityToAppStores < ActiveRecord::Migration
  def change
    add_column :app_stores, :display_priority, :integer
    add_index :app_stores, :display_priority
  end
end
