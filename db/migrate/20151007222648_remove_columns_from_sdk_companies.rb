class RemoveColumnsFromSdkCompanies < ActiveRecord::Migration
  def change
  	remove_column :sdk_companies, :funding
  	remove_column :sdk_companies, :phone
  	remove_column :sdk_companies, :address1
  	remove_column :sdk_companies, :address2
  	remove_column :sdk_companies, :city
  	remove_column :sdk_companies, :state
  	remove_column :sdk_companies, :zip
  	remove_column :sdk_companies, :country
  	remove_column :sdk_companies, :description
  	remove_column :sdk_companies, :year_founded
  	remove_column :sdk_companies, :bloomberg_id
  	remove_column :sdk_companies, :alias_name
  	remove_column :sdk_companies, :alias_website
  end
end
