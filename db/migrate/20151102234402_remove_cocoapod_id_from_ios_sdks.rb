class RemoveCocoapodIdFromIosSdks < ActiveRecord::Migration
  def change
  	remove_column :ios_sdks, :cocoapod_id
  end
end
