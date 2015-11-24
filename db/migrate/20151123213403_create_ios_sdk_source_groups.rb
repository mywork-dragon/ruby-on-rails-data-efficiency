class CreateIosSdkSourceGroups < ActiveRecord::Migration
  def change
    create_table :ios_sdk_source_groups do |t|
      t.string :name
      t.integer :ios_sdk_id
      t.boolean :flagged
      t.timestamps
    end
    add_index :ios_sdk_source_groups, :ios_sdk_id
  end
end
