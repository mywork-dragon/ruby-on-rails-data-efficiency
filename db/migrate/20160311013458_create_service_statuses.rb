class CreateServiceStatuses < ActiveRecord::Migration
  def change
    create_table :service_statuses do |t|
      t.integer :service, null: false
      t.boolean :active, default: true
      t.text :description
      t.text :outage_message
      t.timestamps
    end

    add_index :service_statuses, :service, unique: true
  end
end
