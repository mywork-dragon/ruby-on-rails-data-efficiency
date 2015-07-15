class DoubleIndexIosAppCategoriesSnapshots < ActiveRecord::Migration
  def change
    remove_index :ios_app_categories_snapshots, :ios_app_snapshot_id
    add_index :ios_app_categories_snapshots, [:ios_app_snapshot_id, :ios_app_category_id, :kind], name: 'index_ios_app_snapshot_id_category_id_kind'
    add_index :ios_app_categories_snapshots, :kind
  end
end
