class CreateIosSdkBadges < ActiveRecord::Migration
  def change
    create_table :ios_sdk_badges do |t|
      t.integer :ios_sdk_id
      t.string :username
      t.string :repo_name
      t.timestamps null: false
    end

    add_index :ios_sdk_badges, :ios_sdk_id
    add_index :ios_sdk_badges, [:username, :repo_name], unique: true
    add_index :ios_sdk_badges, :repo_name
  end
end
