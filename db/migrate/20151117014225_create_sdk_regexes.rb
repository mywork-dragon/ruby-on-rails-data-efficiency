class CreateSdkRegexes < ActiveRecord::Migration
  def change
    create_table :sdk_regexes do |t|

      t.string :regex
      t.integer :ios_sdk_id
      t.integer :android_sdk_company_id
      t.timestamps
    end

    add_index :sdk_regexes, :regex, unique: true
    add_index :sdk_regexes, :ios_sdk_id
    add_index :sdk_regexes, :android_sdk_company_id
  end
end
