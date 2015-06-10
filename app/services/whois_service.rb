class WhoisService
  
  def attributes(domain)
    ret = {}
    
    begin
      w = Whois::Client.new
      @result = w.lookup(domain)
      #puts @result
    rescue => e
      return ret
    end

    
    
    methods = %w(
      registrant_name
      country_code
      country_full
      continent
    )
    
    # Go through the list of methods, call each one, and store it in ret
    methods.each do |method|
      key = method.to_sym
      
      begin
        attribute = send(method.to_sym)
        
        ret[key] = attribute
      rescue => e
        ret[key] = nil
      end
      
    end
    
    ret
  end
  
  # Pass it the stuff before the colon
  def value_for_field(field)
    @result.match(Regexp.new("^#{field}:.*$"))[0].gsub("#{field}:", '').strip
  end
  
  def registrant_name
    value_for_field('Registrant Name')
  end
  
  def country_code
    @country_code = value_for_field('Registrant Country')

    begin
      @code = IsoCountryCodes.find(@country_code)
    rescue => e
      @code = nil
    end
    
    @country_code
  end
  
  def country_full
    @code.name
  end
  
  def continent
    @code.continent
  end
  
  
  class << self
    
    # Attributes hash
    # @author Jason Lew
    def attributes(domain)
      self.new.attributes(domain)
    end
    
  end
  

  
end