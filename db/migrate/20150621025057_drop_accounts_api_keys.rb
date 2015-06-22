class DropAccountsApiKeys < ActiveRecord::Migration
  def change
    drop_table :accounts_api_keys
  end
end
