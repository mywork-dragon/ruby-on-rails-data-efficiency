class Company < ActiveRecord::Base
  has_many :installations
  has_many :scraped_results
  enum status: [ :active, :paused ]
  
  # The domain only of the website (minus the 'http://')
  # @author Jason Lew
  def website_domain
    website.gsub(/\Ahttp:\/\//, "")
  end
    
  
end
