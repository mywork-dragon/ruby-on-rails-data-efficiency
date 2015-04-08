class AppController < ApplicationController
  
  def filter_ios_apps
    # results = []
    # IosApps.where
  end
  
  def filter_android_apps
    
  end
  
  # Get details of iOS app.
  # Input: appId (the key for the app in our database; not the appIdentifier)
  def get_ios_app
    appId = params['appId']
    ios_app = IosApp.includes(:ios_app_snapshots).find(appId)
    newest_snapshot = ios_app.newest_snapshot
    app_json = {
      'appId' => appId,
      'appName' => newest_snapshot.name,
      
    }
  end
  
  def get_android_app
    
  end
  
  def get_company
    
  end
  
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
