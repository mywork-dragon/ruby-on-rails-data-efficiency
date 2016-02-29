class CreateIosSdkLinks < ActiveRecord::Migration
  def change
    create_table :ios_sdk_links do |t|
      t.integer :source_sdk_id, null: false
      t.integer :dest_sdk_id, null: false
      t.timestamps
    end

    add_index :ios_sdk_links, :source_sdk_id, unique: true
    add_index :ios_sdk_links, :dest_sdk_id
  end
end
