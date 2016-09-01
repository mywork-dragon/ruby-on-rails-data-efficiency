class ChangeIndiciesOnDeveloperLinkOptions < ActiveRecord::Migration
  def change
    remove_index :developer_link_options, :android_developer_id
    remove_index :developer_link_options, :ios_developer_id
    add_index :developer_link_options, [:android_developer_id, :method]
    add_index :developer_link_options, [:ios_developer_id, :method]
    add_index :developer_link_options, :method
  end
end
