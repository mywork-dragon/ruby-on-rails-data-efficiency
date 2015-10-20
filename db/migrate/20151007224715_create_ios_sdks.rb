class CreateIosSdks < ActiveRecord::Migration
  def change
    create_table :ios_sdks do |t|
    	t.string :name
    	t.string :website
    	t.string :favicon
    	t.boolean :flagged, default: false
      t.integer :cocoapod_id
      t.boolean :open_source

      t.timestamps
    end
    add_index :ios_sdks, :name
    add_index :ios_sdks, :website
    add_index :ios_sdks, :flagged
    add_index :ios_sdks, :cocoapod_id
    add_index :ios_sdks, :open_source
  end
end
