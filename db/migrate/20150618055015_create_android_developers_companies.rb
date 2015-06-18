class CreateAndroidDevelopersCompanies < ActiveRecord::Migration
  def change
    create_table :android_developers_companies do |t|
      t.integer :company_id
      t.integer :android_developer_id

      t.timestamps
    end
    add_index :android_developers_companies, :company_id
    add_index :android_developers_companies, :android_developer_id
  end
end
