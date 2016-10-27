class AddDomainDatumIdToClearbitContacts < ActiveRecord::Migration
  def change
    add_column :clearbit_contacts, :domain_datum_id, :integer
    add_index :clearbit_contacts, :domain_datum_id
  end
end
