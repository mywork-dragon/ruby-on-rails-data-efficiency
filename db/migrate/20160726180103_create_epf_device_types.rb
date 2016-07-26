class CreateEpfDeviceTypes < ActiveRecord::Migration
  def change
    create_table :epf_device_types do |t|
      t.integer :export_date, limit: 8
      t.integer :device_type_id, null: false
      t.text :name
      t.timestamps null: false
    end

    add_index :epf_device_types, :device_type_id, unique: true
  end
end
