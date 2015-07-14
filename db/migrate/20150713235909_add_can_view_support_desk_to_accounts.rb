class AddCanViewSupportDeskToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :can_view_support_desk, :boolean, :null => false, :default => false
  end
end
