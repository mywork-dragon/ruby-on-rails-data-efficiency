class MTurkWorker < ActiveRecord::Base

  has_many :ios_fb_ad_appearances
  has_many :android_fb_ad_appearances
  

end
