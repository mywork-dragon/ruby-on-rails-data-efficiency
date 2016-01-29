class AddDeprecatedToIosDeviceArches < ActiveRecord::Migration
  def change
    add_column :ios_device_arches, :deprecated, :boolean, :default => false
  end
end
