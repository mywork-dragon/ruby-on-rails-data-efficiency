class DownloadsService

SITE = 'xyo.net/iphone-app'
GOOGLE_WORD_LIMIT = 32
  
  class << self
  
    def attributes(app_attrs={})
      
      @app_identifier = app_attrs[:app_identifier]
      name = app_attrs[:name]
      
      query = CGI::escape(name.gsub(/[^0-9a-z ]/i, ''))
  
      url = app_xyo_url(query)
      
      ret = {}
      
      @html = downloads_html(url)
      
      raise "Page doesn't have link to app" if !page_has_link_to_app?
      
      ret[:downloads] = downloads

      ret
    end
    
    #private
    
    def app_xyo_url(query)
      page = Tor.get("http://xyo.net/iphone/#{query}/")
      html = Nokogiri::HTML(page)
      app_boxes = html.css('.search-suggestion > .app-box')
      
      links = []
      
      app_boxes.each do |app_box|
        links << app_box['href']
      end
      
      raise "No links found" if links.empty?    
       
      links.first
    end
    
    def downloads_html(url)
      page = Tor.get(url)
      Nokogiri::HTML(page)
    end 
    
    def page_has_link_to_app?
      @html.css('a.install.button').each do |node|
        return true if node['href'].include?("id#{@app_identifier}")
      end
      
      false
    end
    
    # In dollas
    # @author Jason Lew
    def downloads
      dl_s = @html.at_css('.downloads').at_css('.amount').children[1].text.strip
      
      raise "Could not find downloads" if dl_s.blank?
      
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
      
      raise "End of downloads method"
    end

  end
end