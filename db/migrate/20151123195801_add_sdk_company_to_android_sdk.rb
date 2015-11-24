class AddSdkCompanyToAndroidSdk < ActiveRecord::Migration
  def change
    add_column :android_sdks, :sdk_company_id, :integer
    add_index :android_sdks, :sdk_company_id
  end
end
