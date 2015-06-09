class AddBusinessCountryCodeAndBusinessCountryToJpIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :jp_ios_app_snapshots, :business_country_code, :string
    add_index :jp_ios_app_snapshots, :business_country_code
    
    add_column :jp_ios_app_snapshots, :business_country, :string
    add_index :jp_ios_app_snapshots, :business_country
  end
end
