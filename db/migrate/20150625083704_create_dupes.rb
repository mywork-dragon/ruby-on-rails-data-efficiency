class CreateDupes < ActiveRecord::Migration
  def change
    create_table :dupes do |t|
      t.string :app_identifier
      t.boolean :duped

      t.timestamps
    end
    add_index :dupes, :app_identifier
    add_index :dupes, :duped
  end
end
