class AddInUseToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :in_use, :boolean, index: :true
  end
end
