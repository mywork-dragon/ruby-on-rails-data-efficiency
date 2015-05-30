class CreateAndroidPackageTags < ActiveRecord::Migration
  def change
    create_table :android_package_tags do |t|
      t.text :tag_name

      t.timestamps
    end
  end
end
