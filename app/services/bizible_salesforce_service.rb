class BizibleSalesforceService

  def client

  end

  class << self

    def client
      RestforceService.new.client
    end
    
    def hydrate_lead(options={})
      id = options[:id]
      email = options[:email]
      website = options[:website]
      
      company = 
      
    end

  
  end
  
end
