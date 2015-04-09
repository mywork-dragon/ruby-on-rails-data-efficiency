class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :url

      t.timestamps
    end
    add_index :websites, :url
  end
end
