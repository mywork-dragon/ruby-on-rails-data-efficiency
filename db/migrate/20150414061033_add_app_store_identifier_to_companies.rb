class AddAppStoreIdentifierToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :app_store_identifier, :integer
    add_index :companies, :app_store_identifier, name: 'index_app_store_identifier'
  end
end
