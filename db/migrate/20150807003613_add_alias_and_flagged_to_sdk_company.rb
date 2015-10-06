class AddAliasAndFlaggedToSdkCompany < ActiveRecord::Migration
  def change
  	add_column :sdk_companies, :alias_name, :string
  	add_column :sdk_companies, :alias_website, :string
  	add_column :sdk_companies, :flagged, :boolean, default: false
  	add_index :sdk_companies, :alias_name
  	add_index :sdk_companies, :alias_website
  	add_index :sdk_companies, :flagged
  end
end
