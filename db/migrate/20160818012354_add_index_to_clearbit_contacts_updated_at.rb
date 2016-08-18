class AddIndexToClearbitContactsUpdatedAt < ActiveRecord::Migration
  def change
    add_index :clearbit_contacts, :updated_at
  end
end
