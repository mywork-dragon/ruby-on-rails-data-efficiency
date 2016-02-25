class AddIgnoredToIosSdkSourceData < ActiveRecord::Migration
  def change
    add_column :ios_sdk_source_data, :flagged, :boolean, default: false
    remove_index :ios_sdk_source_data, :name
    add_index :ios_sdk_source_data, [:name, :flagged]
    add_index :ios_sdk_source_data, :flagged
  end
end
