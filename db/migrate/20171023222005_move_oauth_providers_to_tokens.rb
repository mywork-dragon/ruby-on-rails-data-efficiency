class MoveOauthProvidersToTokens < ActiveRecord::Migration
  def change
    change_column :users, :linkedin_token, :text
    change_column :users, :google_token, :text
    change_column :users, :salesforce_token, :text
    change_column :users, :salesforce_image_url, :text
    change_column :users, :profile_url, :text
    change_column :accounts, :salesforce_token, :text
    change_column :accounts, :salesforce_refresh_token, :text
    change_column :accounts, :salesforce_instance_url, :text
  end
end
