class AddNameToIosDeviceModels < ActiveRecord::Migration
  def change
    add_column :ios_device_models, :name, :string
    add_index :ios_device_models, :name
  end
end
