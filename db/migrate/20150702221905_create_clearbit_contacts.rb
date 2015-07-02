class CreateClearbitContacts < ActiveRecord::Migration
  def change
    create_table :clearbit_contacts do |t|
      t.integer :company_id
      t.integer :clearbit_id
      t.string :given_name
      t.string :family_name
      t.string :full_name
      t.string :title
      t.string :email
      t.string :linkedin
      t.date :updated

      t.timestamps
    end
    add_index :clearbit_contacts, :company_id
    add_index :clearbit_contacts, :clearbit_id
  end
end
