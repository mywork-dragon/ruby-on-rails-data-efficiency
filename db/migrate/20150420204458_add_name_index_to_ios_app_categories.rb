class AddNameIndexToIosAppCategories < ActiveRecord::Migration
  def change
    add_index :ios_app_categories, :name
  end
end
