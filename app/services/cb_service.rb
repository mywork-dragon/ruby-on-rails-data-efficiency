class CbService

  SITE = 'crunchbase.com/organization'
  
  NUMBER_OF_RESULTS = 30
  
  

  def initialize
    
  end
  

  class << self
    
    def cb_url(company_name)

      query = company_name
      query_url_safe = CGI::escape(query)

      url = "http://www.google.com/search?num=#{NUMBER_OF_RESULTS}&q=#{query_url_safe}+site:#{SITE}"
    
      puts "Google URL: #{url}"
        
      page = open(url)
    
      url_cache = nil

      html = Nokogiri::HTML(page)
    
      html.search("cite").each do |cite|
        url = cite.inner_text

        org_regex = /crunchbase.com\/organization\/[^\/]*\z/

        if(url.match(org_regex))
          puts url
          
          url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{url}"
      
          puts "Cache URL: #{url_cache}"
          
          break
        end
      end
      
      url_cache
    end 
    
    def cb_funding(cb_url)
      page = open(cb_url)
      html = Nokogiri::HTML(page)
      
      puts html
      
      funding_classes = html.css(".funding_amount")
      
      funding_class = funding_classes.first
      
      puts "funding_class: #{funding_class}"
      
      funding = funding_class.children[1]
      
      puts "\nfunding: #{funding}"
      
      funding
    end
    
    
    def test
      #companies = ["Instagram", "Snapchat", "Pinterest", "Datanyze", "Marketo"]
      
      companies = ["500Friends", "Iterable", "MightySignal", "Secret"]
      
      cb_urls = []
      
      companies.each do |company|
        cb_urls << self.cb_url(company)
      end
      
      fundings = []
      
      cb_urls.each do |cb_url|
        fundings << cb_funding(cb_url)
      end
      
      puts ""
      
      companies.each_with_index do |company, i|
        puts "#{company}: #{fundings[i]}"
      end
      
      
      
    end
    
  end

end