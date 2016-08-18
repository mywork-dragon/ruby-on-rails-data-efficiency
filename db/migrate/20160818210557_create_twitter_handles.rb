class CreateTwitterHandles < ActiveRecord::Migration
  def change
    create_table :twitter_handles do |t|
      t.string :handle
      t.timestamps null: false
    end

    add_index :twitter_handles, :handle, unique: true
  end
end
