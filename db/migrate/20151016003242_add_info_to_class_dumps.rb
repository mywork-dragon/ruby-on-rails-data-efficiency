class AddInfoToClassDumps < ActiveRecord::Migration
  def change
  	add_column :class_dumps, :success, :boolean
  	add_column :class_dumps, :install_success, :boolean
  	add_column :class_dumps, :dump_success, :boolean
  	add_column :class_dumps, :teardown_success, :boolean
  	add_column :class_dumps, :teardown_retry, :boolean

  	add_column :class_dumps, :duration, :float
  	add_column :class_dumps, :install_time, :float
  	add_column :class_dumps, :dump_time, :float
  	add_column :class_dumps, :teardown_time, :float

  	add_column :class_dumps, :error, :text
  	add_column :class_dumps, :trace, :text
  	add_column :class_dumps, :error_root, :text
  	add_column :class_dumps, :error_teardown, :text
  	add_column :class_dumps, :error_teardown_trace, :text

  	add_index :class_dumps, :success
  	add_index :class_dumps, :install_success
  	add_index :class_dumps, :dump_success
  	add_index :class_dumps, :teardown_success
  	add_index :class_dumps, :teardown_retry

  	add_index :class_dumps, :duration
  	add_index :class_dumps, :install_time
  	add_index :class_dumps, :dump_time
  	add_index :class_dumps, :teardown_time
  end
end
