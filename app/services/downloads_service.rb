class DownloadsService

SITE = 'xyo.net/iphone-app'
GOOGLE_WORD_LIMIT = 32
  
  class << self
  
    def attributes(app_attrs={})
      
      @app_identifier = app_attrs[:app_identifier]
      name = app_attrs[:name]
      
      query = CGI::escape(name.gsub(/[^0-9a-z ]/i, ''))
  
      url = app_xyo_url(query)

      #temp

      # return {} if url.nil?
      
      ret = {}
      
      @html = downloads_html(url)
      
      #return {} if @html.nil? || !page_has_link_to_app?
      begin
        ret[:downloads] = downloads
      # rescue
      #   return {}
      end

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
      
      raise "No links found\n\nHTML:\n#{html}" if links.empty?    
        
      return nil if links.empty?
       
      links.first
    end
    
    def downloads_html(url)
      begin
        page = Tor.get(url)
        Nokogiri::HTML(page)
      # rescue
      #   return nil
      end
    end 
    
    def page_has_link_to_app?
      @html.css('a.install.button').each do |node|
        return true if node['href'].include?("id#{@app_identifier}")
      end
      
      raise "Page does not have link to app\n\nHTML:\n#{@html}"
      
      #false
    end
    
    # In dollas
    # @author Jason Lew
    def downloads
      dl_s = @html.at_css('.downloads').at_css('.amount').children[1].text.strip
      
      raise "Could not find downloads\n\nHTML:\n#{@html}" if dl_s.blank?
      #return nil if dl_s.blank?
      
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