class DownloadsService

SITE = 'xyo.net/iphone-app'
  
  class << self
  
    def downloads_attributes(title)
      query_url_safe = CGI::escape(title)

      url = "http://www.google.com/search?num=30&q=#{query_url_safe}+site:#{SITE}"
        
      page = open(url)

      html = Nokogiri::HTML(page)
    
      url = html.search("cite").first.inner_text
      
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
      dl_s = html.at_css('.downloads').at_css('.amount').children[1].text.strip
      
      return nil if dl_s.blank?
      
      regex_thousands = /^(\d)*(\.)*(\d)*[Kk]{1}$/x
      
      if dl_s.match(regex_thousands)
        num = dl_s.gsub(/[Kk]/, "").to_f
        return (num*1000).to_i
      else
        regex_millions = /^(\d)*(\.)*(\d)*[Mm]{1}$/x
        if dl_s.match(regex_millions)
          num = dl_s.gsub(/[Mm]/, "").to_f
          return (num*1000000).to_i
        else
          return dl_s.to_i
        end
      end
    end

  end
end