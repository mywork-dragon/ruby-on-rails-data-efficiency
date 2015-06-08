class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string  :name
      t.timestamps null: false
    end

    add_index :lists, :listable_id

    create_table :lists_users do |t|
      t.belongs_to :user, index: true
      t.belongs_to :list, index: true
      t.timestamps null: false
    end
    
  end
end