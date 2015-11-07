class CreateGithubAccounts < ActiveRecord::Migration
  def change
    create_table :github_accounts do |t|
      t.string :username
      t.string :email
      t.string :password
      t.string :application_name
      t.string :homepage_url
      t.string :callback_url
      t.string :client_id
      t.string :client_secret
      t.datetime :last_used

      t.timestamps
    end

    add_index :github_accounts, :last_used
  end
end
