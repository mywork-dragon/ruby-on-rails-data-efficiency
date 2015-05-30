class CreateAndroidPackages < ActiveRecord::Migration
  def change
    create_table :android_packages do |t|
      t.text :package_name
      t.integer :android_package_tag_id
      t.integer :apk_snapshot_id

      t.timestamps
    end
    add_index :android_packages, :android_package_tag_id
    add_index :android_packages, :apk_snapshot_id
  end
end
