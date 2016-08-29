class AddMatchStringToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :match_string, :string
    add_index :websites, :match_string
  end
end
