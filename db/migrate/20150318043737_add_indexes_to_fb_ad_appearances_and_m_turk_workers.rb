class AddIndexesToFbAdAppearancesAndMTurkWorkers < ActiveRecord::Migration
  def change
    
    add_index :fb_ad_appearances, :aws_assignment_identifier
    add_index :fb_ad_appearances, :hit_identifier
    add_index :m_turk_workers, :aws_identifier
    
  end
end
