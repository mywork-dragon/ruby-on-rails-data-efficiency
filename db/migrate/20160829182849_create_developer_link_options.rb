class CreateDeveloperLinkOptions < ActiveRecord::Migration
  def change
    create_table :developer_link_options do |t|
      t.integer :ios_developer_id
      t.integer :android_developer_id
      t.integer :method
      t.timestamps null: false
    end

    add_index :developer_link_options, :ios_developer_id
    add_index :developer_link_options, :android_developer_id
  end
end
