class CreateEpfStorefronts < ActiveRecord::Migration
  def change
    create_table :epf_storefronts do |t|
      t.integer :export_date, limit: 8
      t.integer :storefront_id
      t.string :country_code
      t.text :name
      t.timestamps null: false
    end

    add_index :epf_storefronts, :storefront_id, unique: true
    add_index :epf_storefronts, :country_code, unique: true
  end
end
