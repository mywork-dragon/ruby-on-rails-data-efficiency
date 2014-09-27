class CreateScrapeJobs < ActiveRecord::Migration
  def change
    create_table :scrape_jobs do |t|
      t.text :notes

      t.timestamps
    end
  end
end
