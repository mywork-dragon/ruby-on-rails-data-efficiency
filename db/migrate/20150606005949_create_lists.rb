class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string  :name
      t.integer :listable_id
      t.string  :listable_type
      t.timestamps null: false
    end

    add_index :lists, :listable_id

    create_table :lists_users do |t|
      t.belongs_to :user, index: true
      t.belongs_to :list, index: true
      t.timestamps null: false
    end

    create_table :listables_lists do |t|
      t.integer :listable_id, index: true
      t.integer :list_id, index: true
      t.string :listable_type
      t.timestamps null: false
    end
  end
end