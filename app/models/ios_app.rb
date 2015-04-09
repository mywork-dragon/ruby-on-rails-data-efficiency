class IosApp < ActiveRecord::Base

  has_many :ios_app_snapshots
  belongs_to :app
  has_many :fb_ad_appearances
  has_many :ios_app_download_snapshots
  has_many :ios_apps_websites  
  has_many :websites, through: :ios_apps_websites
    
  
  def get_newest_app_snapshot
    self.ios_app_snapshots.max_by do |snapshot|
      snapshot.updated_at
    end
  end
  
  def get_newest_download_snapshot
    self.ios_app_download_snapshots.max_by do |snapshot|
      snapshot.updated_at
    end
  end
  
  def get_company
    self.websites.each do |w|
      if w.company.present?
        return w.company
      end
    end
    return nil
  end
  
  def get_website_urls
    self.websites.to_a.map{|w| w.url}
  end
  
end
