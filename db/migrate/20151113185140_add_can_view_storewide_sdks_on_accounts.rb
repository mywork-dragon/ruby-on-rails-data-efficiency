class AddCanViewStorewideSdksOnAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :can_view_storewide_sdks, :boolean, default: false
  end
end
