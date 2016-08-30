class AddUniquenessToUrlOnWebsites < ActiveRecord::Migration
  def change
    remove_index :websites, :url
    add_index :websites, :url, unique: true
  end
end
