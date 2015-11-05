class AddIndexToCocoapods < ActiveRecord::Migration
  def change
  	add_index :cocoapods, [:ios_sdk_id, :version], unique: true
  end
end
