class AppStoreService
  
  class << self
  
    def app_store_attributes(app_store_url)
      ret = {}
      
      url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{app_store_url}"
      
      page = open(url_cache)
      html = Nokogiri::HTML(page)
      
      ret[:company_url] = company_url(html)
      ret[:category] = category(html)
      ret[:updated] = updated(html)
      
      ret
    end
    
    private
    
    def company_url(html)
      url = html.css(".app-links").children.first['href']
      
      UrlManipulator.url_with_http_only(url)
    end
    
    def category(html)
      html.css(".genre").children[1].text
    end
    
    def updated(html)
      Date.parse(html.css(".release-date").children[1].text)
    end
    
  end
end