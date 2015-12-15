class AddIosVersionFmtToIosDevices < ActiveRecord::Migration
  def change
    add_column :ios_devices, :ios_version_fmt, :string
  end
end
