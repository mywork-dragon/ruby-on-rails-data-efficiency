class AddKindAndInUseAndLastUsedToAppleAccounts < ActiveRecord::Migration
  def change
    add_column :apple_accounts, :kind, :integer
    add_column :apple_accounts, :in_use, :integer
    add_column :apple_accounts, :last_used, :datetime

    add_index :apple_accounts, [:last_used, :kind, :in_use]
    add_index :apple_accounts, [:kind, :in_use]
    add_index :apple_accounts, :in_use
  end
end