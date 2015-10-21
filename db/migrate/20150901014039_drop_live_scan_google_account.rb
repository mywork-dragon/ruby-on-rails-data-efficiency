class DropLiveScanGoogleAccount < ActiveRecord::Migration
  def change
  	drop_table :live_scan_google_accounts
  end
end
