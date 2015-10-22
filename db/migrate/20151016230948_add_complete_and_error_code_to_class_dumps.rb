class AddCompleteAndErrorCodeToClassDumps < ActiveRecord::Migration
  def change
  	add_column :class_dumps, :complete, :boolean
  	add_column :class_dumps, :error_code, :integer

  	add_index :class_dumps, :complete
  	add_index :class_dumps, :error_code
  end
end
