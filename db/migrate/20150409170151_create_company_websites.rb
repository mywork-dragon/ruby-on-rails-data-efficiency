class CreateCompanyWebsites < ActiveRecord::Migration
  def change
    create_table :company_websites do |t|
      t.integer :company_id
      t.integer :website_id

      t.timestamps
    end
    add_index :company_websites, :company_id
    add_index :company_websites, :website_id
  end
end
