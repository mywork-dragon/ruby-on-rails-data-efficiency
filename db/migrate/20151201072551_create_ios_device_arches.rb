class CreateIosDeviceArches < ActiveRecord::Migration
  def change
    create_table :ios_device_arches do |t|
      t.string :name

      t.timestamps
    end
    add_index :ios_device_arches, :name
  end
end
