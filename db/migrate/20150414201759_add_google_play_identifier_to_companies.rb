class AddGooglePlayIdentifierToCompanies < ActiveRecord::Migration
  def change
    
    add_column :companies, :google_play_identifier, :string
    add_index :companies, :google_play_identifier, name: 'index_google_play_identifier'
    
  end
end
