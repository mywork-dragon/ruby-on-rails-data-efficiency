class AaService
  
  class << self
    
    # Attributes hash
    # @author Jason Lew
    # @param id The App Store identifier
    def attributes(id, options={})
      @html = aa_html(id)

      ret = {}
    
      ret[:updates] = updates
    
      ret
    end
    
    def aa_html(id)
      page = Tor.get("https://www.appannie.com/apps/ios/app/#{id}")
    
      Nokogiri::HTML(page)
    end
    
    def updates
      whats_new = @html.css('#app_content > div.app_content_section').children.find{ |c| c.text.strip == "What's New"}
      whats_new.next_element
    end
  
    
  end
  
end