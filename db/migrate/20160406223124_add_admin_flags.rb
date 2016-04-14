class AddAdminFlags < ActiveRecord::Migration
  def change
    rename_column :accounts, :god_mode, :is_admin_account
    add_column :users, :is_admin, :boolean, default: false
  end
end
