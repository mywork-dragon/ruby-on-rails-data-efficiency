class AddDisabledToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :disabled, :boolean, default: false
    remove_index :ios_devices, name: "index_ios_devices_on_purpose"
    add_index :ios_devices, [:purpose, :disabled]
    add_index :ios_devices, :disabled
  end
end
