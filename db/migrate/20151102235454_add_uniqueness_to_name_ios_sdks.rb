class AddUniquenessToNameIosSdks < ActiveRecord::Migration
  def change
  	remove_index :ios_sdks, name: "index_ios_sdks_on_name"
  	add_index :ios_sdks, :name, unique: true
  end
end
