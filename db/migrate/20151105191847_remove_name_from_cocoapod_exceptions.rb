class RemoveNameFromCocoapodExceptions < ActiveRecord::Migration
  def change
    remove_column :cocoapod_exceptions, :name
  end
end
