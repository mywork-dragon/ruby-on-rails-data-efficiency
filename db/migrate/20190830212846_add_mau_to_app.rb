class AddMauToApp < ActiveRecord::Migration
  def change
    add_column :android_apps, :mau, :integer
    add_column :android_apps, :mau_monthly_change, :integer

    add_column :ios_apps, :mau, :integer
    add_column :ios_apps, :mau_monthly_change, :integer
  end
end
