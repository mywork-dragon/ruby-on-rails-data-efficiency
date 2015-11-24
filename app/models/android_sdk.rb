class AndroidSdk < ActiveRecord::Base

	belongs_to :sdk_company
  has_many :sdk_packages


  def get_favicon
    if self.favicon.nil?
      host = URI(self.website).host
      return "https://www.google.com/s2/favicons?domain=#{host}"
    else
      return self.favicon
    end
  end

end
