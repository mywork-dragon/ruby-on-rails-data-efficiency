class RemoveUniqueFromFollow < ActiveRecord::Migration
  def change
    # remove unique constraint
    remove_index :follow_relationships, [:followable_type, :followable_id]
    add_index :follow_relationships, [:followable_type, :followable_id]
  end
end
