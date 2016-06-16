class CreateIosAppCategoryNameBackups < ActiveRecord::Migration
  def change
    create_table :ios_app_category_name_backups do |t|
      t.string :name
      t.integer :app_store_id
      t.integer :ios_app_category_id

      t.timestamps null: false
    end

    add_index :ios_app_category_name_backups, [:ios_app_category_id, :app_store_id], name: 'index_backup_on_ios_app_category_id_and_app_store_id'
    add_index :ios_app_category_name_backups, :app_store_id
    add_index :ios_app_category_name_backups, :name
  end
end
