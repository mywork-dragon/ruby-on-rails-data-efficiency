class CreateIosReclassificationMethods < ActiveRecord::Migration
  def change
    create_table :ios_reclassification_methods do |t|
      t.integer :method
      t.boolean :active
      t.timestamps null: false
    end

    add_index :ios_reclassification_methods, :method, unique: true
    add_index :ios_reclassification_methods, :active
  end
end
