class CreateWebsitesDomainData < ActiveRecord::Migration
  def change
    create_table :websites_domain_data do |t|
      t.integer :website_id
      t.integer :domain_datum_id
      t.timestamps null: false
    end

    add_index :websites_domain_data, [:website_id, :domain_datum_id]
    add_index :websites_domain_data, :domain_datum_id
  end
end
