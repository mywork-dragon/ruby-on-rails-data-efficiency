class AddByCopywrightSellerUrlTextSupportUrlTextToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :by, :string unless column_exists?(:ios_app_snapshots, :by)
    add_column :ios_app_snapshots, :copywright, :string column_exists?(:ios_app_snapshots, :copywright)
    add_column :ios_app_snapshots, :seller_url_text, :string column_exists?(:ios_app_snapshots, :seller_url_text)
    add_column :ios_app_snapshots, :support_url_text, :string column_exists?(:ios_app_snapshots, :support_url_text)
  end
end
