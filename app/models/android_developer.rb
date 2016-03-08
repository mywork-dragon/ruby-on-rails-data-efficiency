class AndroidDeveloper < ActiveRecord::Base
  
  validates :identifier, uniqueness: true
  
  belongs_to :company
  has_many :android_apps

  has_many :android_developers_websites
  has_many :websites, through: :android_developers_websites

  def get_website_urls
    self.websites.map{|w| w.url}
  end
end
