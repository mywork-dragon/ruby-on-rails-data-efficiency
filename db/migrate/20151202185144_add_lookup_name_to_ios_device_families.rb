class AddLookupNameToIosDeviceFamilies < ActiveRecord::Migration
  def change
    add_column :ios_device_families, :lookup_name, :string
    add_index :ios_device_families, :lookup_name
  end
end
