class DropAndroidSdkCompaniesAndroidApp < ActiveRecord::Migration
  def change
  	drop_table :android_sdk_companies_android_apps
  end
end
