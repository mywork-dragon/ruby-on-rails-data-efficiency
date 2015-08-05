class AddFaviconToSdkCompany < ActiveRecord::Migration
  def change
  	add_column :sdk_companies, :favicon, :text
  end
end
