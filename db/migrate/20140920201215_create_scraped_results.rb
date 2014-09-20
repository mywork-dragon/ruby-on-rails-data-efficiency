class CreateScrapedResults < ActiveRecord::Migration
  def change
    create_table :scraped_results do |t|
      t.belongs_to :company
      t.string :url
      t.text :raw_html
      t.integer :status
      t.timestamps
    end
    add_index :scraped_results, :company_id
  end
end
