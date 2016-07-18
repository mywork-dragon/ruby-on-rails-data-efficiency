class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :phone
      t.string :crm
      t.string :sdk
      t.string :message
      t.string :lead_source
      t.text :lead_data
      t.timestamps null: false
    end

    add_index :leads, :email
  end
end
