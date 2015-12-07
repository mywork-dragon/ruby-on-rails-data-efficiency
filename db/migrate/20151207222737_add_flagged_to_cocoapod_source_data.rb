class AddFlaggedToCocoapodSourceData < ActiveRecord::Migration
  def change
    add_column :cocoapod_source_data, :flagged, :boolean, default: false
    remove_index :cocoapod_source_data, :name
    add_index :cocoapod_source_data, [:name, :flagged]
    add_index :cocoapod_source_data, :flagged
  end
end
