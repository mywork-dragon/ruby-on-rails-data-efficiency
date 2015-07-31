class AddDeviceToGoogleAccounts < ActiveRecord::Migration
  def change
  	add_column :google_accounts, :device, :integer
  	add_index :google_accounts, :device
  end
end
