class CreateIosDevelopers < ActiveRecord::Migration
  def change
    create_table :ios_developers do |t|
      t.string :name
      t.string :identifier
      t.integer :company_id

      t.timestamps
    end
    add_index :ios_developers, :name
    add_index :ios_developers, :identifier
    add_index :ios_developers, :company_id
  end
end
