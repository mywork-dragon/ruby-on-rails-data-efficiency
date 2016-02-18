class CreateHeaderRegexes < ActiveRecord::Migration
  def change
    create_table :header_regexes do |t|
      t.text :regex
      t.integer :ios_sdk_id

      t.timestamps
    end

    add_index :header_regexes, :ios_sdk_id
  end
end
