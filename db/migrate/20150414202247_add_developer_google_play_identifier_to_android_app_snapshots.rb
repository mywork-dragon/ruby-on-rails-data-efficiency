class AddDeveloperGooglePlayIdentifierToAndroidAppSnapshots < ActiveRecord::Migration
  def change
    
    add_column :android_app_snapshots, :developer_google_play_identifier, :string
    add_index :android_app_snapshots, :developer_google_play_identifier, name: 'index_developer_google_play_identifier'
    
  end
end
