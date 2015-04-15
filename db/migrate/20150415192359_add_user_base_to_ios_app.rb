class AddUserBaseToIosApp < ActiveRecord::Migration
  def change
    add_column :ios_apps, :user_base, :string
  end
end
