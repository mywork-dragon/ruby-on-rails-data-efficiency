class CreateAndroidDevelopers < ActiveRecord::Migration
  def change
    create_table :android_developers do |t|
      t.string :name
      t.string :identifier
      t.integer :company_id

      t.timestamps
    end
    add_index :android_developers, :name
    add_index :android_developers, :identifier
    add_index :android_developers, :company_id
  end
end
