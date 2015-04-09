class DropCompanyWebsitesTable < ActiveRecord::Migration
  def change
    drop_table :company_websites
  end
end
