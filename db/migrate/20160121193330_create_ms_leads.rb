class CreateMsLeads < ActiveRecord::Migration
  def change
    create_table :ms_leads do |t|
      t.integer :ms_lead_finding_job_id
      t.string :name
      t.string :email
      t.integer :ios_sdk_id
      t.timestamps
    end

    add_index :ms_leads, :ms_lead_finding_job_id
    add_index :ms_leads, :ios_sdk_id
    add_index :ms_leads, :email, :unique => true
  end
end
