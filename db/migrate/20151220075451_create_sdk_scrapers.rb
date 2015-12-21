class CreateSdkScrapers < ActiveRecord::Migration
  def change
    create_table :sdk_scrapers do |t|
      t.string :name
      t.string :private_ip
      t.integer :concurrent_apk_downloads

      t.timestamps
    end
    add_index :sdk_scrapers, :private_ip
    add_index :sdk_scrapers, :concurrent_apk_downloads
  end
end
