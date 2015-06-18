class CreateIosDevelopers < ActiveRecord::Migration
  def change
    create_table :ios_developers do |t|
      t.string :name

      t.timestamps
    end
    add_index :ios_developers, :name
  end
end
