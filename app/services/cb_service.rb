class CbService

  SITE = 'crunchbase.com/organization'
  
  NUMBER_OF_RESULTS = 30
  
  # Bizible.com
  def attributes(domain, options={})    
    query_url_safe = CGI::escape(domain)

    url = "http://www.google.com/search?num=#{NUMBER_OF_RESULTS}&q=#{query_url_safe}+site:#{SITE}"
  
    #puts "Google URL: #{url}"
      
    page = open(url)
  
    url_cache = nil

    html = Nokogiri::HTML(page)
  
    html.search("cite").each do |cite|
      url = cite.inner_text
      if(url.match(/crunchbase.com\/organization\/[^\/]*\z/))
        #puts url
        
        url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{url}"
        
        page = open(url_cache)
        html = Nokogiri::HTML(page)
        
        puts company_url = html.css("li.homepage").children[0]['href']
        
        if UrlManipulator.url_with_base_only(company_url).match(domain)
          @html = html
          break
        end
      end
    end
    
    if @html.nil?
      li "Could not find CB page for #{domain}"
      return
    end
    
    ret = {}
    
    ret[:funding] = funding
    
    ret
  end

  def funding
    begin
      funding_classes = @html.css(".funding_amount").first.children[1].text
    rescue
      nil
    end
  end

  class << self
    
    def attributes(domain, options={})  
      self.new.attributes(domain, options)
    end
    
    def test
      #companies = ["Instagram", "Snapchat", "Pinterest", "Datanyze", "Marketo"]
      
      companies = ["Bizible", "Shippable", "Apsalar", "Urban Airship", "Dealflicks", "Apptentive", "Mozio"]
      
      cb_urls = []
      
      companies.each do |company|
        cb_urls << self.cb_url(company)
      end
      
      fundings = []
      
      cb_urls.each do |cb_url|
        fundings << cb_funding_from_cb_url(cb_url)
      end
      
      #puts ""
      
      companies.each_with_index do |company, i|
        puts "#{company}: #{fundings[i]}"
      end
      
      
      
    end
    
  end

end