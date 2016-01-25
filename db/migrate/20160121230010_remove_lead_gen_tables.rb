class RemoveLeadGenTables < ActiveRecord::Migration
  def change
    drop_table :ms_lead_finding_jobs
    drop_table :ms_lead_emails
    drop_table :ms_leads
  end
end
