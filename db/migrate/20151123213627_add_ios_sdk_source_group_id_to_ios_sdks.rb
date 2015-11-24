class AddIosSdkSourceGroupIdToIosSdks < ActiveRecord::Migration
  def change
    add_column :ios_sdks, :ios_sdk_source_group_id, :integer
    add_index :ios_sdks, :ios_sdk_source_group_id
  end
end
