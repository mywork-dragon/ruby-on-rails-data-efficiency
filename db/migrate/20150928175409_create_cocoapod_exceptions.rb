class CreateCocoapodExceptions < ActiveRecord::Migration
  def change
    create_table :cocoapod_exceptions do |t|
    	t.text :name

      t.timestamps
    end
  end
end
