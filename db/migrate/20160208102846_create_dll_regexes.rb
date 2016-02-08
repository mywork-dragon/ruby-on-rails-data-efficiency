class CreateDllRegexes < ActiveRecord::Migration
  def change
    create_table :dll_regexes do |t|
      t.string :regex
      t.integer :android_sdk_id
      t.integer :ios_sdk_id

      t.timestamps
    end
  end
end
