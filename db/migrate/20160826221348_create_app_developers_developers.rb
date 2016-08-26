class CreateAppDevelopersDevelopers < ActiveRecord::Migration
  def change
    create_table :app_developers_developers do |t|
      t.integer :app_developer_id
      t.references :developer, polymorphic: true, index: { name: 'index_app_developers_on_developer_poly', unique: true }
      t.integer :method
      t.boolean :flagged
      t.timestamps null: false
    end

    add_index :app_developers_developers, :app_developer_id
    add_index :app_developers_developers, :developer_id
  end
end
