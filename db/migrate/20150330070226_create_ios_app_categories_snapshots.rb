class CreateIosAppCategoriesSnapshots < ActiveRecord::Migration
  def change
    create_table :ios_app_categories_snapshots do |t|
      t.integer :ios_app_category_id
      t.integer :ios_app_snapshot_id
      t.string :type

      t.timestamps
    end
    add_index :ios_app_categories_snapshots, :ios_app_category_id
    add_index :ios_app_categories_snapshots, :ios_app_snapshot_id
  end
end
