class CreateAccountsApiKeys < ActiveRecord::Migration
  def change
    create_table :accounts_api_keys do |t|
      t.integer :account_id
      t.integer :api_key_id

      t.timestamps
    end
    add_index :accounts_api_keys, :account_id
    add_index :accounts_api_keys, :api_key_id
  end
end
