class AddUdidToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :udid, :string
    add_index :ios_devices, :udid
  end
end
