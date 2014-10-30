class SalesforceController < ApplicationController
  
  def run_test
    current_user = current_salesforce_user
    client = Restforce.new :oauth_token => current_user.oauth_token,
          :refresh_token => current_user.refresh_token,
          :instance_url  => current_user.instance_url,
          :client_id     => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',
          :client_secret => '3173051852013251576'
          
    # client.create('Merchandise', Name: 'Dumdum')
    
    @out = client.query("select Id, Name from Merchandise__c").first.Name
  end
  
end
