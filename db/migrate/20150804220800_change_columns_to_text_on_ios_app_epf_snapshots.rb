class ChangeColumnsToTextOnIosAppEpfSnapshots < ActiveRecord::Migration
  def change
    remove_index :ios_app_epf_snapshots, :title
    change_column :ios_app_epf_snapshots, :title, :text
    
    remove_index :ios_app_epf_snapshots, :company_url
    change_column :ios_app_epf_snapshots, :company_url, :text
    
    remove_index :ios_app_epf_snapshots, :support_url
    change_column :ios_app_epf_snapshots, :support_url, :text
    
    remove_index :ios_app_epf_snapshots, :view_url
    change_column :ios_app_epf_snapshots, :view_url, :text
    
    remove_index :ios_app_epf_snapshots, :artwork_url_large
    change_column :ios_app_epf_snapshots, :artwork_url_large, :text
    
    remove_index :ios_app_epf_snapshots, :copyright
    change_column :ios_app_epf_snapshots, :copyright, :text
  end
end
