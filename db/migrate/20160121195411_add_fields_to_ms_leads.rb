class AddFieldsToMsLeads < ActiveRecord::Migration
  def change
    add_column :ms_leads, :company, :text
    add_column :ms_leads, :website, :text
  end
end
