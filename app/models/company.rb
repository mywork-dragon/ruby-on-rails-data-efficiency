class Company < ActiveRecord::Base
  has_many :installations
  has_many :scraped_results
  has_many :apps
  has_many :websites
  enum status: [ :active, :paused ]
  
  # scope :get_fortune_1000, where(:fortune_1000_rank.present? && :fortune_1000_rank >= 1000)
  # scope :get_fortune_500, where(:fortune_1000_rank.present? && :fortune_1000_rank >= 500)
  
  # The domain only of the website (minus the 'http://')
  # @author Jason Lew
  def website_domain
    website.gsub(/\Ahttp:\/\//, "")
  end
  
  def get_android_apps
    android_apps = []
    self.websites.each do |w|
      android_apps.concat w.android_apps.to_a
    end
    android_apps.uniq
  end
  
  def get_ios_apps
    ios_apps = []
    self.websites.each do |w|
      ios_apps.concat w.ios_apps.to_a
    end
    ios_apps.uniq
  end
      
end
