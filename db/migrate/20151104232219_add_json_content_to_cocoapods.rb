class AddJsonContentToCocoapods < ActiveRecord::Migration
  def change
    add_column :cocoapods, :json_content, :text
  end
end
