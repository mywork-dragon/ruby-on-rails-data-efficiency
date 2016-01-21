class AddLinkedinUrlToMsLeads < ActiveRecord::Migration
  def change
    add_column :ms_leads, :linkedin_url, :text
  end
end
