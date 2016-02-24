class CreateIosSdkSourceData < ActiveRecord::Migration
  def change
    create_table :ios_sdk_source_data do |t|
      t.string :name
      t.integer :ios_sdk_id

      t.timestamps
    end

    add_index :ios_sdk_source_data, :name
    add_index :ios_sdk_source_data, :ios_sdk_id
  end
end
