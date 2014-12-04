class SalesforceController < ApplicationController
  
  protect_from_forgery except: :test_sf_post
  
  # def run_test
  #   current_user = current_salesforce_user
  #   client = Restforce.new :oauth_token => current_user.oauth_token,
  #         :refresh_token => current_user.refresh_token,
  #         :instance_url  => current_user.instance_url,
  #         :client_id     => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',
  #         :client_secret => '3173051852013251576'
  #
  #   @blah = client.create('Merchandise__c', Name: 'Dumdum', Price__c: '123', Quantity__c: '44')
  #
  #   @out = client.query("select Id, Name from Merchandise__c").first.Name
  # end
  #
  
  def test_sf_post
    puts "test_sf_post called"
    
    BizibleSalesforceService.hydrate_lead(params[:lead])
    
    json = {"test_sf_post_called" => "success"}
    
    render json: json
  end
  
  def test_get_token
    puts "test_get_token"
    
    {"test_get_token" => "success"}
    
    render json: json
  end
end
