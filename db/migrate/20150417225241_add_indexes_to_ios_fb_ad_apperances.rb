class AddIndexesToIosFbAdApperances < ActiveRecord::Migration
  def change
    add_index :ios_fb_ad_appearances, :m_turk_worker_id
    add_index :ios_fb_ad_appearances, :ios_app_id
  end
end
