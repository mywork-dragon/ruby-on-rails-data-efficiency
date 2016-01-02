class AddCanViewIosLiveScanToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :can_view_ios_live_scan, :boolean
  end
end
