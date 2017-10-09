class AddCategoryIdToAndroidAppCategories < ActiveRecord::Migration
  def change
    add_column :android_app_categories, :category_id, :string
    add_index :android_app_categories, :category_id, unique: true
  end
end
