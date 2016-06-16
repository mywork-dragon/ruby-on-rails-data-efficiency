class CreateIosAppCategoriesCurrentSnapshotBackups < ActiveRecord::Migration
  def change
    create_table :ios_app_categories_current_snapshot_backups do |t|
      t.integer :ios_app_category_id
      t.integer :ios_app_current_snapshot_id
      t.integer :kind

      t.timestamps null: false
    end

    add_index :ios_app_categories_current_snapshot_backups, :ios_app_category_id, name: 'index_backup_ios_category_snapshot_on_category_id'
    add_index :ios_app_categories_current_snapshot_backups, [:ios_app_current_snapshot_id, :ios_app_category_id, :kind], name: 'index_backup_ios_category_snap_on_snap_id_cat_id_kind'
    add_index :ios_app_categories_current_snapshot_backups, :kind
  end
end
