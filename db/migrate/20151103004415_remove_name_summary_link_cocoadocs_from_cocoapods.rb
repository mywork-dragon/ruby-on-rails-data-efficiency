class RemoveNameSummaryLinkCocoadocsFromCocoapods < ActiveRecord::Migration
  def change
  	remove_index :cocoapods, :cocoadocs
  	remove_index :cocoapods, [:name, :version]

  	remove_column :cocoapods, :name
  	remove_column :cocoapods, :summary
  	remove_column :cocoapods, :link
  	remove_column :cocoapods, :cocoadocs
  end
end
