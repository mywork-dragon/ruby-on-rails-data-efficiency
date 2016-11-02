class AddActiveToIosDeviceFamilies < ActiveRecord::Migration
  def change
    add_column :ios_device_families, :active, :boolean, default: true
    add_index :ios_device_families, :active
  end
end
