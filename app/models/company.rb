class Company < ActiveRecord::Base
  has_many :installations
  has_many :scraped_results
  has_many :apps
  has_many :websites
  has_many :ios_developers
  has_many :android_developers

  enum status: [ :active, :paused ]
  
  validates :app_store_identifier, uniqueness: true, allow_nil: true  #remove for now
  validates :google_play_identifier, uniqueness: true, allow_nil: true
  
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

  def as_json(options={})
    {
      id: self.id,
      name: self.name,
      fortuneRank: self.fortune_1000_rank,
    }
  end
      
end
