class CreateCocoapodTags < ActiveRecord::Migration
  def change
    create_table :cocoapod_tags do |t|
    	t.string :tag
    	t.integer :cocoapod_id

      t.timestamps
    end
    add_index :cocoapod_tags, :tag
    add_index :cocoapod_tags, :cocoapod_id
  end
end
