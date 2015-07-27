class AddAuthTokenToApkSnapshot < ActiveRecord::Migration
  def change
  	add_column :apk_snapshots, :auth_token, :string
    add_index :apk_snapshots, :auth_token
  end
end