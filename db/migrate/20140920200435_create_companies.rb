class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :website
      t.integer :status
      t.timestamps
    end
    add_index :companies, :website, unique: true
  end
end
