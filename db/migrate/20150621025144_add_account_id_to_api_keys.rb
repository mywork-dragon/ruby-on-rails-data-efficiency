class AddAccountIdToApiKeys < ActiveRecord::Migration
  def change
    add_column :api_keys, :account_id, :integer
    add_index :api_keys, :account_id
  end
end
