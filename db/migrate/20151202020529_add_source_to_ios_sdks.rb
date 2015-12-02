class AddSourceToIosSdks < ActiveRecord::Migration
  def change
    add_column :ios_sdks, :source, :integer
  end
end
