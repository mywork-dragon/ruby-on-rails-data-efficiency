class AddIosDeviceArchIdToIosDeviceFamilies < ActiveRecord::Migration
  def change
    add_column :ios_device_families, :ios_device_arch_id, :integer
    add_index :ios_device_families, :ios_device_arch_id
  end
end
