class CreateSdkCompanies < ActiveRecord::Migration
  def change
    create_table :sdk_companies do |t|
    	t.string :name
    	t.string :website
    	t.string :funding
    	t.string :phone
    	t.string :address1
    	t.string :address2
    	t.string :city
    	t.string :state
    	t.string :zip
    	t.string :country
    	t.text :description
    	t.integer :year_founded
    	t.string :bloomberg_id

    	t.timestamps
    end
    add_index :sdk_companies, :name 
    add_index :sdk_companies, :website 
    add_index :sdk_companies, :funding
    add_index :sdk_companies, :year_founded
    add_index :sdk_companies, :state
    add_index :sdk_companies, :zip
    add_index :sdk_companies, :country
    add_index :sdk_companies, :bloomberg_id
  end
end
