class AddAppStoreIdToAppleAccounts < ActiveRecord::Migration
  def change
    add_column :apple_accounts, :app_store_id, :integer
    add_index :apple_accounts, :app_store_id
  end
end
