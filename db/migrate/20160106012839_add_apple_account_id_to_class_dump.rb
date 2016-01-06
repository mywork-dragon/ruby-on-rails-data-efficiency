class AddAppleAccountIdToClassDump < ActiveRecord::Migration
  def change
    add_column :class_dumps, :apple_account_id, :integer
    add_index :class_dumps, :apple_account_id
  end
end
