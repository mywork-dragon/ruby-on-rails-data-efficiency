class BusinessEntityCompanyServiceWorker

  include Sidekiq::Worker
  
  sidekiq_options retry: false
 
  def perform(ids)

  end


  def linkedin_validation(ids)
  	ids.each do |id|
  		c = Company.find_by_id(id)
  		c_name = c.name
  		next if PublicSuffix.valid?(c_name) || c_name.nil?

  		search_url = "https://www.linkedin.com/vsearch/c?keywords=#{URI::encode(c_name)}"
  		search_res = Nokogiri::HTML(open(search_url))

      	links = search_res.xpath("//ol[@id=\"results\"]")

  	end

  	
  end


  
end
