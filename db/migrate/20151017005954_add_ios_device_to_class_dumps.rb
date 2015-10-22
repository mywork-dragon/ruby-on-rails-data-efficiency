class AddIosDeviceToClassDumps < ActiveRecord::Migration
  def change
  	add_column :class_dumps, :ios_device_id, :integer

  	add_index :class_dumps, :ios_device_id
  end
end
