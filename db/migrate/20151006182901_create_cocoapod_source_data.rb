class CreateCocoapodSourceData < ActiveRecord::Migration
  def change
    create_table :cocoapod_source_data do |t|
    	t.string :name
    	t.integer :cocoapod_id

      t.timestamps
    end
    add_index :cocoapod_source_data, :name
    add_index :cocoapod_source_data, :cocoapod_id
    add_index :cocoapod_source_data, [:name, :cocoapod_id], unique: true
  end
end
