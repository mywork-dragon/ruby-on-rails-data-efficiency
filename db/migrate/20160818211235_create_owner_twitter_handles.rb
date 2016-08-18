class CreateOwnerTwitterHandles < ActiveRecord::Migration
  def change
    # http://guides.rubyonrails.org/association_basics.html#polymorphic-associations
    create_table :owner_twitter_handles do |t|
      t.integer :twitter_handle_id
      t.references :owner, polymorphic: true, index: true
      t.timestamps null: false
    end

    add_index :owner_twitter_handles, :owner_id
    add_index :owner_twitter_handles, :twitter_handle_id
  end
end
