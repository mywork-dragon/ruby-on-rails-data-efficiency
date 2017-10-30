class AddAdDataPermissionsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :ad_data_permissions, :text
  end
end
