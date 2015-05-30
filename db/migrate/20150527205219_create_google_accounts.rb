class CreateGoogleAccounts < ActiveRecord::Migration
  def change
    create_table :google_accounts do |t|
      t.text :email
      t.text :password
      t.text :android_id
      t.text :from_ip
      t.boolean :blocked
      t.integer :flags
      t.integer :last_downloaded

      t.timestamps
    end
  end
end
