class MightySignalSalesforceService

  def client
    client = Restforce.new :username => 'j@mightysignal.com',
      :password       => 'asLSKF28247NSKF27FHSF2sf228393cmcmc',
      :security_token => 'yXBgql1B0JUPu0GohhJDJWizg',
      :client_id      => '3MVG9fMtCkV6eLhfXRLFXm5bB33M9zWRtcxVATBCSngDb2p.Nv6k4VP34XD5I8alebb7tPULNIWLVn2W1Jrs3',
      :client_secret  => '3251786618628033245'
  end

  class << self

    def client
      MightySignalSalesforceService.new.client
    end
    
    def create_lead(options={})
      first_name = options[:first_name]
      last_name = options[:last_name]
      company = options[:company]
      email = options[:email]
      phone = options[:phone]
      message = options[:message]
      
      client = self.client
      
      client.create('Lead', 'FirstName' => first_name, 'LastName' => last_name, 'Company' => company, 
                      'Email' => email, 'Phone' => phone, 'Description' => message)
    
    end
    
    def read_dummy
      out = client.query("select Id, LastName from Lead").first.LastName
    end
  
  end
  
end
