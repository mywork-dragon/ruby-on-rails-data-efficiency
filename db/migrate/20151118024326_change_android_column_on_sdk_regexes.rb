class ChangeAndroidColumnOnSdkRegexes < ActiveRecord::Migration
  def change
    rename_column :sdk_regexes, :android_sdk_company_id, :android_sdk_id
  end
end
