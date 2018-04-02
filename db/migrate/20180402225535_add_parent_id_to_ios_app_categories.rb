class AddParentIdToIosAppCategories < ActiveRecord::Migration
  def change
    add_column :ios_app_categories, :parent_identifier, :integer
    add_index :ios_app_categories, :parent_identifier
  end
end
