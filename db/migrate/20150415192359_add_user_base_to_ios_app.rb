class AddUserBaseToIosApp < ActiveRecord::Migration
  def change
    add_column :ios_apps, :user_base, :integer
    add_index :ios_apps, :user_base
  end
end
