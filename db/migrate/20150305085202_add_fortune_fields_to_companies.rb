class AddFortuneFieldsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :fortune_1000_rank, :integer
    add_column :companies, :ceo_name, :string
    add_column :companies, :street_address, :string
    add_column :companies, :city, :string
    add_column :companies, :zip_code, :string
    add_column :companies, :state, :string
  end
end
