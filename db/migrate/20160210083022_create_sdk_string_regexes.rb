class CreateSdkStringRegexes < ActiveRecord::Migration
  def change
    create_table :sdk_string_regexes do |t|
      t.text :regex
      t.integer :min_matches, default: 0
      t.integer :ios_sdk_id

      t.timestamps
    end

    add_index :sdk_string_regexes, :ios_sdk_id
  end
end
