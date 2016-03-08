class CreateAndroidDevelopersWebsites < ActiveRecord::Migration
  def change
    create_table :android_developers_websites do |t|
      t.integer :android_developer_id
      t.integer :website_id
      t.timestamps
    end

    add_index :android_developers_websites, :website_id
    add_index :android_developers_websites, [:android_developer_id, :website_id], name: 'android_dev_id_and_website_id'
  end
end
