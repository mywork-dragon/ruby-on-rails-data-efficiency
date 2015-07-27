class ChangeAuthTokenToTextInApkSnapshot < ActiveRecord::Migration
  def change
  	remove_index :apk_snapshots, :auth_token
  	change_column :apk_snapshots, :auth_token, :text
  end
end