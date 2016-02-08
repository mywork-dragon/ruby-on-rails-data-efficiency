class AddKindToAndroidSdks < ActiveRecord::Migration
  def change
    add_column :android_sdks, :kind, :integer
    add_index :android_sdks, :kind
  end
end
