class RestforceService

  def client
    # client = Restforce.new :username => 'jason@mightysignal.com',
    #   :password       => 'knKnsjnsansaf23764KSJANFssas',
    #   :security_token => 'vZyFBHo9FHpqRWjDUhsIrjzdM',
    #   :client_id      => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',
    #   :client_secret  => '3173051852013251576'
    
    client = Restforce.new :oauth_token => 'oauth token',
      :refresh_token => 'refresh token',
      :instance_url  => 'http://localhost:3000/auth/salesforce/callback',
      :client_id     => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',  #Consumer Key
      :client_secret => '3173051852013251576' #Consumer Secret
  end

  class << self

    def client
      RestforceService.new.client
    end
  
    def run_test
      client = self.client
    
      #@blah = client.create('Merchandise__c', Name: 'Dumdum', Price__c: '123', Quantity__c: '44')

      out = client.query("select Id, Name from Merchandise__c").first.Name
  
      puts "query result: #{out}"
    
    end
  
  end
  
end
