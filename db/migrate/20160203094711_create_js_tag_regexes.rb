class CreateJsTagRegexes < ActiveRecord::Migration
  def change
    create_table :js_tag_regexes do |t|
      t.text :regex
      t.integer :android_sdk_id
      t.integer :ios_sdk_id

      t.timestamps
    end
    add_index :js_tag_regexes, :android_sdk_id
    add_index :js_tag_regexes, :ios_sdk_id
  end
end
