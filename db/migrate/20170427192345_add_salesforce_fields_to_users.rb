class AddSalesforceFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :salesforce_uid, :string
    add_column :users, :salesforce_token, :string
    add_column :users, :salesforce_name, :string
    add_column :users, :salesforce_image_url, :string
  end
end
