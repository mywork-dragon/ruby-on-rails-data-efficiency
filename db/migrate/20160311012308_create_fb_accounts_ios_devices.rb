class CreateFbAccountsIosDevices < ActiveRecord::Migration
  def change
    create_table :fb_accounts_ios_devices do |t|
      t.integer :fb_account_id
      t.integer :ios_device_id
      t.boolean :flagged, :default => false
      t.timestamps
    end

    add_index :fb_accounts_ios_devices, [:fb_account_id, :ios_device_id], name: 'index_fb_account_id_ios_device_id'
    add_index :fb_accounts_ios_devices, :ios_device_id
  end
end
