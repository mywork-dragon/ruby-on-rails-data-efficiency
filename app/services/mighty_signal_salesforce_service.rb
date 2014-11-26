class MightySignalSalesforceService

  def client
    client = Restforce.new :username => 'j@mightysignal.com',
      :password       => 'knKnsjnsansaf23764KSJANFssas',
      :security_token => '',
      :client_id      => '',
      :client_secret  => ''
  end

  class << self

    def client
      RestforceService.new.client
    end
  
  end
  
end
