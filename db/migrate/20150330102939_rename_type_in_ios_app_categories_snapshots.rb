class RenameTypeInIosAppCategoriesSnapshots < ActiveRecord::Migration
  def change
    rename_column :ios_app_categories_snapshots, :type, :kind
  end
end
