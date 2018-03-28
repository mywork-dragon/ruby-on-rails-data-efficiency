class AddFeaturePermissionsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :feature_permissions, :text
  end
end
