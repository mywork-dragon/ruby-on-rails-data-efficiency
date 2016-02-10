class CreateSdkFileRegexes < ActiveRecord::Migration
  def change
    create_table :sdk_file_regexes do |t|
      t.text :regex
      t.integer :android_sdk_id
      t.integer :ios_sdk_id

      t.timestamps
    end

    add_index :sdk_file_regexes, :android_sdk_id
    add_index :sdk_file_regexes, :ios_sdk_id
  end
end
