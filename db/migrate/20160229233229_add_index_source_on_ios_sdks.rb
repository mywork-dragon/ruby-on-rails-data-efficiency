class AddIndexSourceOnIosSdks < ActiveRecord::Migration
  def change
    add_index :ios_sdks, :source
  end
end
