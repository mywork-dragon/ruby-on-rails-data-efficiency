class AddAccessRevokedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_revoked, :boolean, default: false
  end
end
