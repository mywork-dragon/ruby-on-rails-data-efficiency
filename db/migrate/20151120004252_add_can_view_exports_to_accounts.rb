class AddCanViewExportsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :can_view_exports, :boolean, default: true
  end
end
