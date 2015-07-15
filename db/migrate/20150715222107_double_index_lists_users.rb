class DoubleIndexListsUsers < ActiveRecord::Migration
  def change
    remove_index :lists_users, :list_id
    add_index :lists_users, [:list_id, :user_id]
  end
end
