class AddAppStoreIdentifierToCompanies < ActiveRecord::Migration
  def change
    
    add_column :companies, :app_store_identifier, :string
    
  end
end
