class IosDeveloper < ActiveRecord::Base

  validates :identifier, uniqueness: true

  belongs_to :company
  has_many :ios_apps
  
  has_many :ios_developers_websites
  has_many :websites, through: :ios_developers_websites  


  def get_website_urls
    self.websites.map{|w| w.url}
  end

end
