class AddHasFwFolderToClassdumps < ActiveRecord::Migration
  def change
  	add_column :class_dumps, :has_fw_folder, :boolean

  	add_index :class_dumps, :has_fw_folder
  end
end
