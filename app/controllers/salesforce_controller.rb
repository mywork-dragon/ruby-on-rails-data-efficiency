class SalesforceController < ApplicationController
  
  protect_from_forgery except: :test_sf_post
  
  def test_sf_post
    puts "test_sf_post called"
    
    json = {"test_sf_post_called" => "success"}
    
    render json: json
    
    BizibleSalesforceService.hydrate_lead(params[:lead])
    
  end
  
  def test_get_token
    puts "test_get_token"
    
    {"test_get_token" => "success"}
    
    render json: json
  end
  
end
