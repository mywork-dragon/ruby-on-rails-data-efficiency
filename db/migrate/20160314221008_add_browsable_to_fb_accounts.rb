class AddBrowsableToFbAccounts < ActiveRecord::Migration
  def change
    add_column :fb_accounts, :browsable, :boolean, default: false
  end
end
