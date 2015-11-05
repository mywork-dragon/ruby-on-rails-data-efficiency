class AddIosSdkToCocoapods < ActiveRecord::Migration
  def change
  	add_column :cocoapods, :ios_sdk_id, :integer
  end
end
