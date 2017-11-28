class CreateIosClassificationFrameworks < ActiveRecord::Migration
  def change
    create_table :ios_classification_frameworks do |t|
      t.string :name, null: false
      t.integer :ios_sdk_id
      t.timestamps null: false
    end

    add_index :ios_classification_frameworks, [:ios_sdk_id, :name]
    add_index :ios_classification_frameworks, :name, unique: true
  end
end
