class DoubleIndexListablesLists < ActiveRecord::Migration
  def change
    remove_index :listables_lists, :listable_id
    add_index :listables_lists, [:listable_id, :list_id, :listable_type], name: 'index_listable_id_list_id_listable_type'
  end
end
