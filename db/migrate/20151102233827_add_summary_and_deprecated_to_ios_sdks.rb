class AddSummaryAndDeprecatedToIosSdks < ActiveRecord::Migration
  def change
  	add_column :ios_sdks, :summary, :text
  	add_column :ios_sdks, :deprecated, :boolean

  	add_index :ios_sdks, :deprecated
  end
end
