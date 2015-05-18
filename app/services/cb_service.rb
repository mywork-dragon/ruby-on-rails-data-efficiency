class CbService

  SITE = 'crunchbase.com/organization'
  
  NUMBER_OF_RESULTS = 30
  
  # Bizible.com
  def attributes(domain, options={})    
    query_url_safe = CGI::escape(domain)

    url = "http://www.google.com/search?num=#{NUMBER_OF_RESULTS}&q=#{query_url_safe}+site:#{SITE}"
  
    #ld "Google URL: #{url}"
      
    page = Tor.get(url)
  
    url_cache = nil

    html = Nokogiri::HTML(page)
  
    html.search("cite").each do |cite|
      url = cite.inner_text
      if(url.match(/crunchbase.com\/organization\/[^\/]*\z/))
        #ld url
        
        url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{url}"
        
        page = open(url_cache, "User-Agent" => UserAgent.random_web)
        html = Nokogiri::HTML(page)
        
        company_url = html.css("li.homepage").children[0]['href']
        
        # closed = html.css("div.details.definition-list").children.map(&:text).include?('Closed:')
        
        if UrlHelper.url_with_base_only(company_url.downcase).include?(domain.downcase)
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
    ret[:funding_text] = funding_text
    ret[:ipo] = ipo
    ret[:acquired] = acquired
    
    ret
  end

  def funding
    text = funding_text
    
    return nil if text.nil?
    
    text.downcase!
    
    conversion = {' thousand' => 1e3, ' million' => 1e6, ' billion' => 1e9}
    
    ret = nil
    
    conversion.each do |key, value|
      if text.include?(key)
        text.gsub!(key, '')
        ret = text.to_f*value
        break
      end
    end
    
    ret.to_i
  end
  
  def funding_text
    begin
      funding_classes = @html.css(".funding_amount").first.children[1].text
    rescue
      nil
    end
  end
  
  def ipo
    @html.css('.overview-stats').children.map(&:text).include?('IPO / Stock')
  end
  
  def acquired
    @html.css('.overview-stats').children.map(&:text).any?{ |s| s.match(/\AAcquired/) }
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