class CreateEpfFullFeeds < ActiveRecord::Migration
  def change
    create_table :epf_full_feeds do |t|
      
      t.string :name

      t.timestamps
    end
    
    add_index :epf_full_feeds, :name
    
  end
end
