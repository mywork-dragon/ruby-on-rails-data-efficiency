class AddUniqueToNameIosSdkSourceDatas < ActiveRecord::Migration
  def change
    add_index :ios_sdk_source_data, :name, unique: true
  end
end
