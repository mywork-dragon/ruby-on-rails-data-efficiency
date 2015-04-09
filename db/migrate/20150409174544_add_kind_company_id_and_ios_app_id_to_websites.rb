class AddKindCompanyIdAndIosAppIdToWebsites < ActiveRecord::Migration
  def change
    
    add_column :websites, :kind, :integer
    add_index :websites, :kind
    
    add_column :websites, :company_id, :integer 
    add_index :websites, :company_id
    
    add_column :websites, :ios_app_id, :integer
    add_index :websites, :ios_app_id
    
  end
end
