class CreateGoogleAccounts < ActiveRecord::Migration
  def change
    create_table :google_accounts do |t|
      t.string :email
      t.string :password
      t.string :android_identifier
      t.integer :proxy_id
      t.boolean :blocked
      t.integer :flags
      t.datetime :last_used

      t.timestamps
    end
    add_index :google_accounts, :proxy_id 
    add_index :google_accounts, :blocked 
    add_index :google_accounts, :flags
    add_index :google_accounts, :last_used
  end
end