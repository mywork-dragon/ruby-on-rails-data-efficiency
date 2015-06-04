class WhoisService
  
  def attributes(domain)
    ret = {}
    
    w = Whois::Client.new
    @result = w.lookup(domain)
    
    methods = %w(
      country
    )
    
    # Go through the list of methods, call each one, and store it in ret
    methods.each do |method|
      key = method.to_sym
      
      begin
        attribute = send(method.to_sym)
        
        ret[key] = attribute
      rescue
        ret[key] = nil
      end
      
    end
    
    ret
  end
  
  def country
    @result.match(/^Registrant Country:.*$/)[0].gsub('Registrant Country:', '').strip
  end
  
  class << self
    
    # Attributes hash
    # @author Jason Lew
    def attributes(domain)
      self.new.attributes(domain)
    end
    
  end
  

  
end