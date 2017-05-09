class AddSalesforcePermissionToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :can_use_salesforce, :boolean, default: false
  end
end
