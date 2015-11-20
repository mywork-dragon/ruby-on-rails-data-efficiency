class AddDescriptionToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :description, :text
  end
end
