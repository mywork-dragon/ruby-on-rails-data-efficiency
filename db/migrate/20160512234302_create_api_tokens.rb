class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.integer :account_id
      t.string :token, null: false
      t.integer :rate_window, default: 0
      t.integer :rate_limit, default: 2500
      t.boolean :active, default: true
      t.timestamps null: false
    end

    add_index :api_tokens, :account_id
    add_index :api_tokens, [:token, :active], unique: true
  end
end
