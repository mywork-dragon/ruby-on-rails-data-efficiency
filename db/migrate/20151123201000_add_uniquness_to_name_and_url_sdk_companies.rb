class AddUniqunessToNameAndUrlSdkCompanies < ActiveRecord::Migration
  def change
    remove_index :sdk_companies, name: "index_sdk_companies_on_name"
    remove_index :sdk_companies, name: "index_sdk_companies_on_website"

    add_index :sdk_companies, :name, unique: true
    add_index :sdk_companies, :website, unique: true
  end
end
