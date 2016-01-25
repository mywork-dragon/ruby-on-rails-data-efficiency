class CreateMsLeadEmails < ActiveRecord::Migration
  def change
    create_table :ms_lead_emails do |t|
      t.string :email
      t.boolean :flagged, :default => false
      t.timestamps
    end
  end
end
