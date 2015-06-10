class AddIdentifiedAndNotUsefulToAndroidPackages < ActiveRecord::Migration
  def change
    add_column :android_packages, :identified, :boolean
    add_column :android_packages, :not_useful, :boolean
  end
end
