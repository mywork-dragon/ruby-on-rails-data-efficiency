class CreateCocoapodAuthors < ActiveRecord::Migration
  def change
    create_table :cocoapod_authors do |t|
    	t.string :name
    	t.text :email
    	t.integer :cocoapod_id

      t.timestamps
    end
    add_index :cocoapod_authors, :name
    add_index :cocoapod_authors, :cocoapod_id
  end
end
