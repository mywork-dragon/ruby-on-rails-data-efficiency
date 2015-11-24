class CreateAppleAccounts < ActiveRecord::Migration
  def change
    create_table :apple_accounts do |t|
      t.string :email
      t.string :password
      t.integer :ios_device_id

      t.timestamps
    end
    add_index :apple_accounts, :email
    add_index :apple_accounts, :ios_device_id
  end
end
