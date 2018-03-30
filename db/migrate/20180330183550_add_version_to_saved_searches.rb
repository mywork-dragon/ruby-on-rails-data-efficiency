class AddVersionToSavedSearches < ActiveRecord::Migration
  def change
    add_column :saved_searches, :version, :string, :null => false, :default => 'v1'
  end
end
