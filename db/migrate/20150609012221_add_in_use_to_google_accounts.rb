class AddInUseToGoogleAccounts < ActiveRecord::Migration
  def change
    add_column :google_accounts, :in_use, :boolean
  end
end
