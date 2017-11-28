class AddUidToIosSdks < ActiveRecord::Migration
  def change
    add_column :ios_sdks, :uid, :string
    add_index :ios_sdks, :uid, unique: true
  end
end
