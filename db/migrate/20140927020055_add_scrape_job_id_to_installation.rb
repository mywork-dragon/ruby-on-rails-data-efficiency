class AddScrapeJobIdToInstallation < ActiveRecord::Migration
  def change
    add_column :installations, :scrape_job_id, :integer
    
    add_index :installations, :scrape_job_id
  end
end
