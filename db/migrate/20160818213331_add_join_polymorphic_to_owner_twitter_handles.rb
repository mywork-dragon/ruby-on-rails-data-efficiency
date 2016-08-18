class AddJoinPolymorphicToOwnerTwitterHandles < ActiveRecord::Migration
  def change
    add_index :owner_twitter_handles, [:owner_type, :owner_id, :twitter_handle_id], name: 'index_owner_twitter_handle_poly_join'
  end
end
