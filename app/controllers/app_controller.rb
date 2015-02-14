class AppController < ApplicationController
  
  def app_info
    
  end
  
  def app_info_get_signals
    url = params['url']
    
    services = ('a'..'z').to_a
    
    json = {services: services}
    
    render json: json
  end
  
  
end
