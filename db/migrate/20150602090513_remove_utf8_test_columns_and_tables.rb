class RemoveUtf8TestColumnsAndTables < ActiveRecord::Migration
  def change
    drop_table :dummy_models
    
    remove_column :sidekiq_testers, :dummy_string
    remove_column :sidekiq_testers, :dummy_text
    
    remove_column :sidekiq_testers, :dummy_string2
    remove_column :sidekiq_testers, :dummy_text2
   
    remove_column :sidekiq_testers, :dummy_string3
    remove_column :sidekiq_testers, :dummy_text3
    
    remove_column :sidekiq_testers, :dummy_string4
    remove_column :sidekiq_testers, :dummy_text4
    
    remove_column :sidekiq_testers, :is_it_medium_text
  end
end
