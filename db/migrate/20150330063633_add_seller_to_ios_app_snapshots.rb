class AddSellerToIosAppSnapshots < ActiveRecord::Migration
  def change
    add_column :ios_app_snapshots, :seller, :string
  end
end
