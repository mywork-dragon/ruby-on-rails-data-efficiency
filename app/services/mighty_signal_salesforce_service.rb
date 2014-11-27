class MightySignalSalesforceService

  def client
    client = Restforce.new :username => 'jasonlew@mightysignal.com',
      :password       => 'saAHSaslfnKAJSNFKJ2147682647KJSAHKFJH128947',
      :security_token => '',
      :client_id      => '',
      :client_secret  => ''
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
