class AddOauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_uid, :string
    add_column :users, :google_token, :string
    add_column :users, :linkedin_uid, :string
    add_column :users, :linkedin_token, :string
  end
end
