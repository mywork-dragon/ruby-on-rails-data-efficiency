class AddIndexesBetweenIosAppsAndCompanies < ActiveRecord::Migration
  def change
    add_index :ios_apps_websites, [:ios_app_id, :website_id]
    add_index :websites, [:id, :company_id]
  end
end
