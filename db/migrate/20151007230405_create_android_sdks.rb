class CreateAndroidSdks < ActiveRecord::Migration
  def change
    create_table :android_sdks do |t|
    	t.string :name
    	t.string :website
    	t.string :favicon
    	t.boolean :flagged, default: false
      t.boolean :open_source

      t.timestamps
    end
    add_index :android_sdks, :name
    add_index :android_sdks, :website
    add_index :android_sdks, :flagged
    add_index :android_sdks, :open_source
  end
end
