class DropOldEpfTables < ActiveRecord::Migration
  def change
    drop_table :epf_storefronts
    drop_table :epf_application_device_types
    drop_table :epf_device_types
    drop_table :epf_applications
  end
end
