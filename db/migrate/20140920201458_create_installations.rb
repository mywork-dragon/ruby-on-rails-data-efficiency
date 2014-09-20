class CreateInstallations < ActiveRecord::Migration
  def change
    create_table :installations do |t|
      t.belongs_to :company
      t.belongs_to :service
      t.belongs_to :scraped_result
      t.timestamps
    end
    add_index :installations, :company_id
    add_index :installations, :service_id
    add_index :installations, :scraped_result_id
  end
end
