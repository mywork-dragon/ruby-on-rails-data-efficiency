class AddAppleAccountIdToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :apple_account_id, :integer
    add_index :ios_devices, :apple_account_id
  end
end
