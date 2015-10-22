class AddInAmericaToAndroidApp < ActiveRecord::Migration
  def change
  	add_column :android_apps, :in_america, :boolean, default: true
  	add_index :android_apps, :in_america
  end
end
