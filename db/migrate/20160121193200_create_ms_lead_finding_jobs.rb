class CreateMsLeadFindingJobs < ActiveRecord::Migration
  def change
    create_table :ms_lead_finding_jobs do |t|
      t.text :notes
      t.timestamps
    end
  end
end
