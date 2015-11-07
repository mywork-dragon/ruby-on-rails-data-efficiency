class CreateIosSdkUpdates < ActiveRecord::Migration
  def change
    create_table :ios_sdk_updates do |t|
      t.string :cocoapods_sha
      t.timestamps
    end
    add_index :ios_sdk_updates, :cocoapods_sha
  end
end
