class AddCanViewAdAttributionToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :can_view_ad_attribution, :boolean, default: false
  end
end
