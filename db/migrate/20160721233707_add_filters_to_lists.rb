class AddFiltersToLists < ActiveRecord::Migration
  def change
    add_column :lists, :filter, :text
  end
end
