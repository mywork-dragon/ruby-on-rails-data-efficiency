class RemoveUserIdFromFollow < ActiveRecord::Migration
  def change
    remove_index :follow_relationships, :user_id
    remove_column :follow_relationships, :user_id
  end
end
