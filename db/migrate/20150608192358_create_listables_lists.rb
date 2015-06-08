class CreateListablesLists < ActiveRecord::Migration
  def change
    create_table :listables_lists do |t|
      t.integer :listable_id
      t.integer :list_id
      t.string :listable_type

      t.timestamps
    end
    add_index :listables_lists, :listable_id
    add_index :listables_lists, :list_id
    add_index :listables_lists, :listable_type
  end
end
