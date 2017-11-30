class AddSalesforceSyncingToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :salesforce_syncing, :boolean, default: false
  end
end
