class CreateAndroidPackages < ActiveRecord::Migration
  def change
    create_table :android_packages do |t|
      t.string :package_name
      t.integer :apk_snapshot_id
      t.integer :android_package_tag

      t.timestamps
    end
    add_index :android_packages, :package_name
    add_index :android_packages, :apk_snapshot_id
    add_index :android_packages, :android_package_tag
  end
end
