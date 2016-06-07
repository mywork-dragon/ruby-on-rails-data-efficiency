class AddAuthTokenToGoogleAccounts < ActiveRecord::Migration
  def change
    add_column :google_accounts, :auth_token, :string
  end
end
