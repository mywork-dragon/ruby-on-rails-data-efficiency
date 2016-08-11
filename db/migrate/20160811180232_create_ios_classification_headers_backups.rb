class CreateIosClassificationHeadersBackups < ActiveRecord::Migration
  def change
    create_table :ios_classification_headers_backups do |t|
      t.string :name
      t.integer :ios_sdk_id
      t.boolean :is_unique
      t.text :collision_sdk_ids
      t.timestamps null: false
    end

    add_index :ios_classification_headers_backups, :name, unique: true
    add_index :ios_classification_headers_backups, [:ios_sdk_id, :is_unique], name: 'index_ios_header_backup_sdk_id_unique'
    add_index :ios_classification_headers_backups, :is_unique
  end
end
