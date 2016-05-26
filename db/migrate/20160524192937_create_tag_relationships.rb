class CreateTagRelationships < ActiveRecord::Migration
  def change
    create_table :tag_relationships do |t|
      t.integer :tag_id
      t.integer :taggable_id
      t.string :taggable_type
      t.timestamps null: false
    end
    add_index :tag_relationships, :tag_id
    add_index :tag_relationships, [:taggable_type, :taggable_id]
    add_index :tag_relationships, [:tag_id, :taggable_id, :taggable_type], name: 'index_on_tag_id_and_taggable_id_and_type'
  end
end
