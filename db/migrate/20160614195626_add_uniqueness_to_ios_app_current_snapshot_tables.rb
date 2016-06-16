class AddUniquenessToIosAppCurrentSnapshotTables < ActiveRecord::Migration
  def change
    remove_index :ios_app_categories, :category_identifier
    add_index :ios_app_categories, :category_identifier, unique: true

    remove_index :ios_app_category_names, name: 'index_on_ios_app_category_id_and_app_store_id'
    add_index :ios_app_category_names, [:ios_app_category_id, :app_store_id], name: 'index_on_ios_app_category_id_and_app_store_id', unique: true
    remove_index :ios_app_category_name_backups, name: 'index_backup_on_ios_app_category_id_and_app_store_id'
    add_index :ios_app_category_name_backups, [:ios_app_category_id, :app_store_id], name: 'index_backup_on_ios_app_category_id_and_app_store_id', unique: true
  end
end
