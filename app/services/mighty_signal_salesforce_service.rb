require 'restforce'

class MightySignalSalesforceService

  def client
    client = Restforce.new :username => 'jasonlew@mightysignal.com',
      :password       => 'saAHSaslfnKAJSNFKJ2147682647KJSAHKFJH128947',
      :security_token => 'PN1W6fcEY2Pa7DI44l2Ubc5b',
      :client_id      => '3MVG9fMtCkV6eLhcIlf3UM3DhI0qHjleFYx1eiGwILdwEf8djU26Vnqjd3mu1Kxs0Z258R99eC0sfRJHG548g',
      :client_secret  => '6384884061761347258'
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
      crm = options[:crm]

      client.create!('Lead', 'FirstName' => first_name, 'LastName' => last_name, 'Company' => company, 'Email' => email, 'Phone' => phone, 'Message__c' => message, 'CRM__C' => crm)
    
    end
    
    def read_dummy
      out = client.query("select Id, LastName from Lead ORDER BY CreatedDate DESC").first
    end
  
  end
  
end
