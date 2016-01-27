class CreateIosSdksMsClearbitLeads < ActiveRecord::Migration
  def change
    create_table :ios_sdks_ms_clearbit_leads do |t|
      t.integer :ios_sdk_id
      t.integer :ms_clearbit_lead_id
      t.timestamps
    end

    add_index :ios_sdks_ms_clearbit_leads, [:ms_clearbit_lead_id, :ios_sdk_id], name: 'index_clearbit_id_ios_sdk_id'
    add_index :ios_sdks_ms_clearbit_leads, :ios_sdk_id, name: 'index_ios_sdk_id'
  end
end
