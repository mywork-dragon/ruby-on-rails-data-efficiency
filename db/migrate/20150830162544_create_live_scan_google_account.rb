class CreateLiveScanGoogleAccount < ActiveRecord::Migration
  def change
    create_table :live_scan_google_accounts do |t|
      t.string :email
      t.string :password
      t.string :android_identifier
      t.integer :proxy_id
      t.boolean :blocked
      t.integer :flags
      t.datetime :last_used
      t.boolean :in_use
      t.integer :device

      t.timestamps
    end
    add_index :live_scan_google_accounts, :proxy_id 
    add_index :live_scan_google_accounts, :blocked 
    add_index :live_scan_google_accounts, :flags
    add_index :live_scan_google_accounts, :last_used
    add_index :live_scan_google_accounts, :in_use
    add_index :live_scan_google_accounts, :device
  end
end
