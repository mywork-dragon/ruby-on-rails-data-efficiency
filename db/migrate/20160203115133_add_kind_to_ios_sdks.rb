class AddKindToIosSdks < ActiveRecord::Migration
  def change
    add_column :ios_sdks, :kind, :integer
    add_index :ios_sdks, :kind
  end
end
