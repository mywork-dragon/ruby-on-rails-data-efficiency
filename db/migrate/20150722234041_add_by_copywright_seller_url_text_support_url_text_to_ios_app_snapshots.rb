class AddByCopywrightSellerUrlTextSupportUrlTextToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :by, :string
    add_column :ios_app_snapshots, :copywright, :string
    add_column :ios_app_snapshots, :seller_url_text, :string
    add_column :ios_app_snapshots, :support_url_text, :string
  end
end
