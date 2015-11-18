class RecreateSdkPackages < ActiveRecord::Migration
  def change
    create_table :sdk_packages do |t|
      t.string :package
      t.integer :ios_sdk_id
      t.integer :android_sdk_id
      t.timestamps
    end

    add_index :sdk_packages, :package, unique: true
    add_index :sdk_packages, :ios_sdk_id
    add_index :sdk_packages, :android_sdk_id
  end
end
