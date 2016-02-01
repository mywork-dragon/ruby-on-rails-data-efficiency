class CreateFbAccounts < ActiveRecord::Migration
  def change
    create_table :fb_accounts do |t|
      t.string :username
      t.string :password
      t.datetime :last_browsed
      t.datetime :last_scraped
      t.boolean :flagged, :default => false
      t.timestamps
    end
  end
end
