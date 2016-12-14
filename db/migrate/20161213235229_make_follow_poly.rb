class MakeFollowPoly < ActiveRecord::Migration
  def change
    add_column :follow_relationships, :follower_id, :integer
    add_column :follow_relationships, :follower_type, :string
    add_index :follow_relationships, [:follower_type, :follower_id]
  end
end
