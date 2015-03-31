class DownloadsService

SITE = 'xyo.net/iphone-app'
GOOGLE_WORD_LIMIT = 32
  
  class << self
  
    def attributes(app_attrs={})
      
      @app_identifier = app_attrs[:app_identifier]
      
      # if app_attrs[:description]
      #   query_url_safe = CGI::escape(app_attrs[:description])
      # else
      #   query_url_safe = CGI::escape(app_attrs[:title])
      # end
      
      description = app_attrs[:description]
      
      google_special_chars = ['"', '+', '&', '$', '#', '-', '_']
      
      google_special_chars.each do |c|
        description.gsub!(c, '')
      end
      
      description_truncated = description.split[0...(GOOGLE_WORD_LIMIT - 1)].join(' ')  # -1 because using site
      
      query_url_safe = CGI::escape(app_attrs[:title] + ' ' + description_truncated)
      
      full_query = "site:#{SITE}+#{query_url_safe}"

      url = "https://www.google.com/search?num=30&q=#{full_query}"
      
      #li "url: #{url}"
        
      page = Tor.get(url)

      html = Nokogiri::HTML(page)
      
      url = nil
    
      html.search("cite").map{|x| x.inner_text}.each do |link|
        if link.include?(SITE)
          url = "http://#{link}"
          break
        end
      end
      
      #ld "XYO URL: #{url}"
      
      return {downloads: nil} if url.nil?
      
      ret = {}
      
      @html = downloads_html(url)
      
      
      
      return {downloads: nil} unless page_has_link_to_app? 
      
      ret[:downloads] = downloads
      
      ret
      
      #ratings(html)
    end
    
    #private
    
    def downloads_html(url)
      puts "url: #{url}"
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