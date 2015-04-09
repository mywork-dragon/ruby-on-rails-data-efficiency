class AddIndexesToAndroidAppCategoriesSnapshots < ActiveRecord::Migration
  def change
    add_index :android_app_categories_snapshots, :android_app_category_id, name: 'index_android_app_category_id'
    add_index :android_app_categories_snapshots, :android_app_snapshot_id, name: 'index_android_app_snapshot_id'
  end
end
