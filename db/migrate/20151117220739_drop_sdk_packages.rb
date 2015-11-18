class DropSdkPackages < ActiveRecord::Migration
  def change
    drop_table :sdk_packages
  end
end
