class CreateCompaniesIosDevelopers < ActiveRecord::Migration
  def change
    create_table :companies_ios_developers do |t|
      t.integer :company_id
      t.integer :ios_developer_id

      t.timestamps
    end
    add_index :companies_ios_developers, :company_id
    add_index :companies_ios_developers, :ios_developer_id
  end
end
