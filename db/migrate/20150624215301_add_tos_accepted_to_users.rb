class AddTosAcceptedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tos_accepted, :boolean, default: false
    add_index :users, :tos_accepted
  end
end
