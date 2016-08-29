class CreateAppDevelopers < ActiveRecord::Migration
  def change
    create_table :app_developers do |t|
      t.string :name
      t.boolean :flagged, default: false
      t.timestamps null: false
    end

    add_index :app_developers, :name
  end
end
