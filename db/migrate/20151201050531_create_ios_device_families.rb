class CreateIosDeviceFamilies < ActiveRecord::Migration
  def change
    create_table :ios_device_families do |t|
      t.string :name

      t.timestamps
    end
  end
end
