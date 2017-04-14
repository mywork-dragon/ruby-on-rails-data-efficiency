class AddAccountUuidToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :mightysignal_id, :string
  end
end
