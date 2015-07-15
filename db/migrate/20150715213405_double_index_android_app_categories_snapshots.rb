class DoubleIndexAndroidAppCategoriesSnapshots < ActiveRecord::Migration
  def change
    remove_index :android_app_categories_snapshots, name: 'index_android_app_snapshot_id'
    add_index :android_app_categories_snapshots, [:android_app_snapshot_id, :android_app_category_id], name: 'index_android_app_snapshot_id_category_id'
  end
end
