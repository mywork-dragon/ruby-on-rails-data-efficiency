class AddSdkCompanyToIosSdk < ActiveRecord::Migration
  def change
    add_column :ios_sdks, :sdk_company_id, :integer
    add_index :ios_sdks, :sdk_company_id
  end
end
