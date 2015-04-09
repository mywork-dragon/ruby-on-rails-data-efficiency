class ApiController < ApplicationController
  
  skip_before_filter  :verify_authenticity_token
  
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
    ios_app = IosApp.includes(:ios_app_snapshots, websites: :company).find(appId)
    company = ios_app.get_company #could be nil, if no websites, or websites don't have company
    app_json = {
      'appId' => appId,
      'appName' => ios_app.newest_snapshot.name,
      'companyName' => company.present? ? company.name : nil,
      'companyId' => company.present? ? company.id : nil,
      'mobilePriority' => nil, #look into how we're calculating mobile priority
      'adSpend' => nil, #get need to merge ad spend data
      'fortuneRank' => company.present? ? company.fortune_1000_rank : nil, #check with Jason if we have this; look into fortune 1000
      'funding' => company.present? ? company.funding : nil,
      'countriesDeployed' => nil, #not part of initial launch
      'countryHq' => {
        'streetAddress' => company.present? ? company.street_address : nil,
        'city' => company.present? ? company.city : nil,
        'zipCode' => company.present? ? company.zip_code : nil,
        'state' => company.present? ? company.state : nil,
        'country' => company.present? ? company.country : nil
      },
      'downloads' => ios_app.downloads,
      'lastUpdated' => nil, #not available yet; look in released
      'updateFreq' => nil, #not available yet; hold off on this
      'appIcon' => {
        'large' => ios_app.icon_url_350x350,
        'small' => ios_app.icon_url_175x175
      },
      'companyWebsites' => ios_app.get_website_urls, #this is an array
      'appIdentifier' => ios_app.id
    }
    render json: app_json
  end
  
  def get_android_app

  end
  
  def get_company
    
  end
  
  def app_info
    
  end
end
