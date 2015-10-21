class AddMethodToClassDumps < ActiveRecord::Migration
  def change
  	add_column :class_dumps, :method, :string

  	add_index :class_dumps, :method
  end
end
