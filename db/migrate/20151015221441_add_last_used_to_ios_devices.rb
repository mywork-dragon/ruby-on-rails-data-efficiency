class AddLastUsedToIosDevices < ActiveRecord::Migration
  def change
  	add_column :ios_devices, :last_used, :datetime
  	add_index :ios_devices, :last_used
  end
end
