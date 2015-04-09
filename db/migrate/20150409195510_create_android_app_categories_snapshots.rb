class CreateAndroidAppCategoriesSnapshots < ActiveRecord::Migration
  def change
    create_table :android_app_categories_snapshots do |t|
      t.integer :android_app_category_id
      t.integer :android_app_snapshot_id

      t.timestamps
    end
  end
end
