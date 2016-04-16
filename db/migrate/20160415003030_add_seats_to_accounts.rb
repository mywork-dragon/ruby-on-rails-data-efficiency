class AddSeatsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :seats_count, :integer, default: 5
  end
end
