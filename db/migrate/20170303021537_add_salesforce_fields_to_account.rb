class AddSalesforceFieldsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :salesforce_uid, :string
    add_column :accounts, :salesforce_token, :string
    add_column :accounts, :salesforce_refresh_token, :string
    add_column :accounts, :salesforce_instance_url, :string
    add_column :accounts, :salesforce_settings, :text
  end
end
