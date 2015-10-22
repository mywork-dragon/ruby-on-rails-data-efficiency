class CreateIosDevices < ActiveRecord::Migration
  def change
    create_table :ios_devices do |t|
      t.string :serial_number
      t.string :ip
      t.integer :purpose

      t.timestamps
    end
    add_index :ios_devices, :serial_number
    add_index :ios_devices, :ip
    add_index :ios_devices, :purpose
  end
end
