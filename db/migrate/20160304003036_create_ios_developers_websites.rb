class CreateIosDevelopersWebsites < ActiveRecord::Migration
  def change
    create_table :ios_developers_websites do |t|
      t.integer :ios_developer_id
      t.integer :website_id
      t.timestamps
    end
    add_index :ios_developers_websites, :website_id
    add_index :ios_developers_websites, [:ios_developer_id, :website_id]
  end
end
