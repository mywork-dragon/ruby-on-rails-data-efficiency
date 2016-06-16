class AddUniquenessToIosAppCurrentCategoriesJoin < ActiveRecord::Migration
  def change
    remove_index :ios_app_categories_current_snapshots, name: 'index_on_ios_app_snapshot_ios_app_category_id_kind'
    add_index :ios_app_categories_current_snapshots, [:ios_app_current_snapshot_id, :ios_app_category_id, :kind], unique: true, name: 'index_on_ios_app_snapshot_ios_app_category_id_kind'

    remove_index :ios_app_categories_current_snapshot_backups, name: 'index_backup_ios_category_snap_on_snap_id_cat_id_kind'
    add_index :ios_app_categories_current_snapshot_backups, [:ios_app_current_snapshot_id, :ios_app_category_id, :kind], unique: true, name: 'index_backup_ios_category_snap_on_snap_id_cat_id_kind'
  end
end
