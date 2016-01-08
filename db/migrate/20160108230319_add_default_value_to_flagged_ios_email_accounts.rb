class AddDefaultValueToFlaggedIosEmailAccounts < ActiveRecord::Migration
  def change
    change_column_default :ios_email_accounts, :flagged, false
  end
end
