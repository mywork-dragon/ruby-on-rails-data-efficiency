class AddIosDeviceModelIdToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :ios_device_model_id, :integer
    add_index :ios_devices, :ios_device_model_id
  end
end
