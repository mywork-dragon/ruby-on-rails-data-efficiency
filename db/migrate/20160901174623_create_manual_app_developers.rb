class CreateManualAppDevelopers < ActiveRecord::Migration
  def change
    create_table :manual_app_developers do |t|
      t.string :name
      t.text :ios_developer_ids
      t.text :android_developer_ids
      t.boolean :flagged, default: false
      t.timestamps null: false
    end

    add_index :manual_app_developers, :name
  end
end
