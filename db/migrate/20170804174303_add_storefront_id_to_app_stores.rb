class AddStorefrontIdToAppStores < ActiveRecord::Migration
  def change
    add_column :app_stores, :storefront_id, :string
  end
end
