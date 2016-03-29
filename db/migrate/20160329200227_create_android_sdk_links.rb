class CreateAndroidSdkLinks < ActiveRecord::Migration
  def change
    create_table :android_sdk_links do |t|
      t.integer :source_sdk_id
      t.integer :dest_sdk_id

      t.timestamps
    end
    add_index :android_sdk_links, :source_sdk_id, unique: true
    add_index :android_sdk_links, :dest_sdk_id
  end
end
