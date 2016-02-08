class CreateSdkJsTags < ActiveRecord::Migration
  def change
    create_table :sdk_js_tags do |t|
      t.string :name

      t.timestamps
    end
    add_index :sdk_js_tags, :name, unique: true
  end
end
