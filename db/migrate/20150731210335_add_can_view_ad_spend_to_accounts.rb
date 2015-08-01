class AddCanViewAdSpendToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :can_view_ad_spend, :boolean, :null => false, :default => true
  end
end
