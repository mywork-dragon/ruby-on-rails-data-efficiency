class CreateEpfApplicationDeviceTypes < ActiveRecord::Migration
  def change
    create_table :epf_application_device_types do |t|
      t.integer :export_date, limit: 8
      t.integer :application_id
      t.integer :device_type_id
      t.timestamps null: false
    end

    add_index :epf_application_device_types, [:application_id, :device_type_id], unique: true, name: 'index_epf_app_device_type'
    add_index :epf_application_device_types, :device_type_id
  end
end
