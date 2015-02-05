class AppStoreService
  
  class << self
  
    def app_website(app_store_url)
      url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{app_store_url}"
      
      page = open(url_cache)
      html = Nokogiri::HTML(page)
      
      url = html.css(".app-links").children.first['href']
      
      UrlManipulator.url_with_http_only(url)
    end
    
  end
end