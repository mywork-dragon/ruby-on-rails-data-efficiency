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
      the_updates = @html.css('#app_content > div.app_content_section').children.find{ |c| c.text.strip == "What's New"}.next_element.children
      
      versions = the_updates.css('h5').select{|u| u.text.match(/.* (.*)/)}
      notes = the_updates.css('.app-version-note').to_a
      
      ret = []
      
      versions.each_with_index do |v, i|
        v_text = v.text
        
        version = v_text.gsub(/ \(.*\)/, '').strip
        date_as_text = v_text.match(/\(.*\)/)[0].gsub('(', '').gsub(')', '').strip
        date = Date.parse(date_as_text)
        
        n_text = notes.to_a.fetch(i, nil)
        
        if n_text.nil?
          text = nil
        else
          text = n_text.text 
          text = text.strip.gsub(/Expand notes\z/, '').strip
          text = I18n.transliterate(text)
        end
        
        ret << {version: version, date: date, text: text}  
      end
      
      ret
      
      
    end
  
    
  end
  
end