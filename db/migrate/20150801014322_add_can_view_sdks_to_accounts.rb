class AddCanViewSdksToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :can_view_sdks, :boolean, :null => false, :default => false
  end
end
