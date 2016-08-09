class CreateDomainData < ActiveRecord::Migration
  def change
    create_table :domain_data do |t|
      t.string :clearbit_id
      t.string :name
      t.string :legal_name
      t.string :domain
      t.text :description
      t.string :company_type
      t.text :tags
      t.string :sector
      t.string :industry_group
      t.string :industry
      t.string :sub_industry
      t.text :tech_used
      t.integer :founded_year
      t.string :time_zone
      t.integer :utc_offset
      t.string :street_number
      t.string :street_name
      t.string :sub_premise
      t.string :city
      t.string :postal_code
      t.string :state
      t.string :state_code
      t.string :country
      t.string :country_code
      t.decimal :lat
      t.decimal :lng
      t.string :logo_url
      t.string :facebook_handle
      t.string :linkedin_handle
      t.string :twitter_handle
      t.string :twitter_id
      t.string :crunchbase_handle
      t.boolean :email_provider
      t.string :ticker
      t.string :phone
      t.integer :alexa_us_rank
      t.integer :alexa_global_rank
      t.integer :google_rank
      t.integer :employees
      t.string :employees_range
      t.integer :market_cap, limit: 8
      t.integer :raised, limit: 8
      t.integer :annual_revenue, limit: 8
      t.timestamps null: false
    end

    add_index :domain_data, :domain
    add_index :domain_data, [:state_code, :country_code]
    add_index :domain_data, :country_code
    add_index :domain_data, :employees
    add_index :domain_data, :market_cap
    add_index :domain_data, :annual_revenue
    add_index :domain_data, :raised
  end
end
