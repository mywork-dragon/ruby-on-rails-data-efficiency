class CreateSalesforceUsers < ActiveRecord::Migration
  def change
    create_table :salesforce_users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :oauth_token
      t.string :refresh_token
      t.string :instance_url

      t.timestamps
    end
  end
end
