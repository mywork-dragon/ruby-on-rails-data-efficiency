#require 'Restforce'

class RestforceService

  def client
    # client = Restforce.new :username => 'jason@mightysignal.com',
    #   :password       => 'knKnsjnsansaf23764KSJANFssas',
    #   :security_token => 'vZyFBHo9FHpqRWjDUhsIrjzdM',
    #   :client_id      => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',
    #   :client_secret  => '3173051852013251576'
    
    # client = Restforce.new :oauth_token => 'oauth token',
    #   :refresh_token => 'refresh token',
    #   :instance_url  => 'http://localhost:3000/auth/salesforce/callback',
    #   :client_id     => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',  #Consumer Key
    #   :client_secret => '3173051852013251576' #Consumer Secret
    
    client = Restforce.new :oauth_token => '00Dj0000000HYFY!AQwAQP2CiObkXglzvSSu9HfbIE8Jx9fAb.4rfz2tmST849er80NuPg7b9DE.Nqqoofq71drVyLLCTYpyLGWGd11vCo1UKa9.',
      :instance_url  => 'https://na16.salesforce.com'
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
    
    def get_token
      body = { 'grant_type' => 'authorization_code', 
                'client_id' => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl', 
                'client_secret' => '3173051852013251576',
                'redirect_uri' => 'http://localhost:3000/auth/salesforce/callback'
              }
      
      result = HTTParty.post('https://na1.salesforce.com/services/oauth2/token', 
          :body => body )
    end
    
    def test_write_signals
      client = self.client
  
      signals = "Signal 1\nSignal 2\nSignal 3\nSignal 4"
      client.update('Lead', Id: '00Qj0000002dxHZ', MightySignal_Signals__c: signals)
    end
  
  end
  
end
