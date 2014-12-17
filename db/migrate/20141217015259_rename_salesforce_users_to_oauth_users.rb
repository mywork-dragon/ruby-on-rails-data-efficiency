class RenameSalesforceUsersToOauthUsers < ActiveRecord::Migration
  def change
    rename_table :salesforce_users, :oauth_users
  end
end
