class AddEmailToSalesforceUsers < ActiveRecord::Migration
  def change
    add_column :salesforce_users, :email, :string
  end
end
