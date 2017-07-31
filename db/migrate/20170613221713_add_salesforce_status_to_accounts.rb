class AddSalesforceStatusToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :salesforce_status, :integer, default: 0
  end
end
