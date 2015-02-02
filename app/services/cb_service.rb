class CbService

  SITE = 'crunchbase.com/organization'
  NUMBER_OF_RESULTS = 30
  
  

  def initialize
    
  end
  
  def cb_url(company_name)

    query = company_name
    query_url_safe = CGI::escape(query)

    url = "http://www.google.com/search?num=#{NUMBER_OF_RESULTS}&q=#{query_url_safe}+site:#{SITE}"
    
    puts "Google URL: #{url}"
    
    page = open(url)

    html = Nokogiri::HTML page
    
    html.search("cite").each do |cite|
      url = cite.inner_text

      org_regex = /crunchbase.com\/organization\/[^\/]*\z/

      if(url.match(org_regex))
        puts url
      end
    end
  end 


end