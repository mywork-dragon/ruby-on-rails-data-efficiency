class AddDomainToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :domain, :string
    add_index :websites, :domain
  end
end
