class AddKindToAndroidAppCategoriesSnapshots < ActiveRecord::Migration
  def change
    
    add_column :android_app_categories_snapshots, :kind, :integer
    
  end
end
