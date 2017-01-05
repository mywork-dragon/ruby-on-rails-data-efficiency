class AddPurposeAndInUseToFbAccounts < ActiveRecord::Migration
  def change
    add_column :fb_accounts, :purpose, :integer
    add_column :fb_accounts, :in_use, :boolean, default: false

    add_index :fb_accounts, [:purpose, :in_use]
  end

end
