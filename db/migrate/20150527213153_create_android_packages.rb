class CreateAndroidPackages < ActiveRecord::Migration
  def change
    create_table :android_packages do |t|
      t.string :package_name
      t.integer :apk_snapshot_id

      t.timestamps
    end
    add_index :android_packages, :package_name
    add_index :android_packages, :apk_snapshot_id
  end
end
