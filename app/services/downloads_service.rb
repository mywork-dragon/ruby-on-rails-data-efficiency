class DownloadsService
  
  class << self
  
    def downloads_attributes(url)
      ret = {}
      
      html = downloads_html(url)
      
      ret[:downloads] = downloads(html)
      
      ret
      
      #ratings(html)
    end
    
    #private
    
    def downloads_html(url)
      url_cache = "http://webcache.googleusercontent.com/search?q=cache:#{url}"
      
      page = open(url_cache)
      Nokogiri::HTML(page)
    end 
    
    # In dollas
    # @author Jason Lew
    def downloads(html)
      html.at_css('.downloads').at_css('.amount').children[1].text.strip
    end

  end
end