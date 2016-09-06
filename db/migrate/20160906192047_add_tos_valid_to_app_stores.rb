class AddTosValidToAppStores < ActiveRecord::Migration
  def change
    add_column :app_stores, :tos_valid, :boolean, default: true
    add_column :app_stores, :tos_url_path, :text
    add_index :app_stores, :tos_valid
  end
end
