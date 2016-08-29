class AddAccountSuccessToClassDumps < ActiveRecord::Migration
  def change
    add_column :class_dumps, :account_success, :integer
    add_index :class_dumps, :account_success
  end
end
