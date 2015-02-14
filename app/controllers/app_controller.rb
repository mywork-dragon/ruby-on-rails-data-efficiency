class AppController < ApplicationController
  
  def app_info
    
  end
  
  def app_info_get_signals
    url = params['url']
    
    attributes = IosAppService.attributes(url)
    
    signals = attributes.map{|key, value| "#{key}: #{value}" }
    
    json = {signals: signals}
    
    puts "json: #{json}"
    
    render json: json
  end
  
  
end
