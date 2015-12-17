class AddUniquenessToNameAndroidSdks < ActiveRecord::Migration
  def change
    remove_index :android_sdks, name: "index_android_sdks_on_name"
    add_index :android_sdks, :name, unique: true
  end
end
