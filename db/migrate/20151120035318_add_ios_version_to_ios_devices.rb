class AddIosVersionToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :ios_version, :string, index: true
  end
end
