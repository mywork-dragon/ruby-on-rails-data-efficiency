class AddEmailIndexToClearbitContacts < ActiveRecord::Migration
  def change
    add_index :clearbit_contacts, :email
  end
end
