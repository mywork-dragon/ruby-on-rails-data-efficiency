class CreateGoogleAccounts < ActiveRecord::Migration
  def change
    create_table :google_accounts do |t|
      t.text :email
      t.text :password
      t.text :android_id
      t.integer :proxy_id
      t.boolean :blocked
      t.integer :flags

      t.timestamps
    end
    add_index :google_accounts, :proxy_id 
  end
end