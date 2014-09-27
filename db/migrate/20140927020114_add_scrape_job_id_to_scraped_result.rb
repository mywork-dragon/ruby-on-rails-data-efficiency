class AddScrapeJobIdToScrapedResult < ActiveRecord::Migration
  def change
    add_column :scraped_results, :scrape_job_id, :integer
    
    add_index :scraped_results, :scrape_job_id
  end
end
