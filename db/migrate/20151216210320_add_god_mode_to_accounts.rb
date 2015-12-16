class AddGodModeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :god_mode, :boolean, default: false
  end
end
