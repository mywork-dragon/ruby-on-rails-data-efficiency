class CreateFollowRelationships < ActiveRecord::Migration
  def change
    create_table :follow_relationships do |t|
      t.integer :user_id, null: false
      t.integer :followable_id, null: false
      t.string :followable_type, null: false
      t.timestamps
    end
    add_index :follow_relationships, :user_id
    add_index :follow_relationships, [:followable_type, :followable_id], unique: true
  end
end
