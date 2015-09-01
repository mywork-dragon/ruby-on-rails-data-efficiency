class AddScrapeTypeToGoogleAccount < ActiveRecord::Migration
  def change
  	add_column :google_accounts, :scrape_type, :integer, default: 0
  	add_index :google_accounts, :scrape_type
  end
end
