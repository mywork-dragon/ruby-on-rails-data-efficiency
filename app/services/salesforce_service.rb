module SalesforceService
  
  # @author Jason Lew
  def initialize(options={})
    @client = nil
  end
  
  def client
    return @client if @client
    
    @client = Restforce.new :username => 'jasonlew@mightysignal.com',
      :password       => 'saAHSaslfnKAJSNFKJ2147682647KJSAHKFJH128947',
      :security_token => 'PN1W6fcEY2Pa7DI44l2Ubc5b',
      :client_id      => '3MVG9fMtCkV6eLhcIlf3UM3DhI0qHjleFYx1eiGwILdwEf8djU26Vnqjd3mu1Kxs0Z258R99eC0sfRJHG548g',
      :client_secret  => '6384884061761347258'
  end
  
  # The current date and time in the string format the Salesforce can read
  # @author Jason Lew
  def current_date_time_sf_format
    d = DateTime.now
    d.strftime("%Y-%m-%dT%H:%M:%S%:z")
  end
  
  class << self
    
  end
  
end