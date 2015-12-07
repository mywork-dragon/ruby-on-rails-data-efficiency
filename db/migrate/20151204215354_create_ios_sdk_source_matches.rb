class CreateIosSdkSourceMatches < ActiveRecord::Migration
  def change
    create_table :ios_sdk_source_matches do |t|

      t.integer :source_sdk_id
      t.integer :match_sdk_id
      t.integer :collisions
      t.integer :total
      t.float :ratio
      t.timestamps
    end

    add_index :ios_sdk_source_matches, :source_sdk_id
    add_index :ios_sdk_source_matches, :ratio
  end
end
