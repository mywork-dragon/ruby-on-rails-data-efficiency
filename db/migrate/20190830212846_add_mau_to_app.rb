class AddMauToApp < ActiveRecord::Migration
  def change
    add_column :android_apps, :mau, :decimal
    add_column :android_apps, :mau_monthly_change, :decimal

    add_column :ios_apps, :mau, :decimal
    add_column :ios_apps, :mau_monthly_change, :decimal
  end
end
