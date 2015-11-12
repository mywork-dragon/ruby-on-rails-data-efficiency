class AddIsParentToAndroidSdkCompanies < ActiveRecord::Migration
  def change
    add_column :android_sdk_companies, :is_parent, :boolean

    add_index :android_sdk_companies, [:name, :flagged, :is_parent], name: 'index_android_sdk_companies_name_flagged_is_parent'

  end
end
