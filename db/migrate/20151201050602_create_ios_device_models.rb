class CreateIosDeviceModels < ActiveRecord::Migration
  def change
    create_table :ios_device_models do |t|
      t.integer :ios_device_family_id

      t.timestamps
    end
    add_index :ios_device_models, :ios_device_family_id
  end
end
