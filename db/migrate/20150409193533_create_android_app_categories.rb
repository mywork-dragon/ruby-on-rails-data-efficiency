class CreateAndroidAppCategories < ActiveRecord::Migration
  def change
    create_table :android_app_categories do |t|
      t.string :name

      t.timestamps
    end
    add_index :android_app_categories, :name
  end
end
