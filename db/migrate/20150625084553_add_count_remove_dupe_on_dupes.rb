class AddCountRemoveDupeOnDupes < ActiveRecord::Migration
  def change
    remove_column :dupes, :duped
    add_column :dupes, :count, :integer
    add_index :dupes, :count
  end
end
