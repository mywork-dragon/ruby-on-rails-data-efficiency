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
    newest_app_snapshot = ios_app.get_newest_app_snapshot
    newest_download_snapshot = ios_app.get_newest_download_snapshot
    app_json = {
      'appId' => appId,
      'appName' => newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      'companyName' => company.present? ? company.name : nil,
      'companyId' => company.present? ? company.id : nil,
      'mobilePriority' => nil, 
      'adSpend' => nil, 
      'fortuneRank' => company.present? ? company.fortune_1000_rank : nil, 
      'funding' => company.present? ? company.funding : nil,
      'countriesDeployed' => nil, #not part of initial launch
      'countryHq' => {
        'streetAddress' => company.present? ? company.street_address : nil,
        'city' => company.present? ? company.city : nil,
        'zipCode' => company.present? ? company.zip_code : nil,
        'state' => company.present? ? company.state : nil,
        'country' => company.present? ? company.country : nil
      },
      'downloads' => newest_download_snapshot.present? ? newest_download_snapshot.downloads : nil,
      'lastUpdated' => newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
      'updateFreq' => nil, 
      'appIcon' => {
        'large' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_350x350 : nil,
        'small' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
      },
      'companyWebsites' => ios_app.get_website_urls, #this is an array
      'appIdentifier' => ios_app.id
    }
    render json: app_json
  end
  
  def get_android_app
    appId = params['appId']
    android_app = AndroidApp.includes(:android_app_snapshots).find(appId)
    company = android_app.get_company
    newest_app_snapshot = android_app.get_newest_app_snapshot
    newest_download_snapshot = android_app.get_newest_download_snapshot
    
    app_json = {
      'appId' => appId,
      'appName' => newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      'companyName' => company.present? ? company.name : nil,
      'companyId' => company.present? ? company.id : nil,
      'mobilePriority' => nil, 
      'adSpend' => nil, 
      'fortuneRank' => company.present? ? company.fortune_1000_rank : nil, 
      'funding' => company.present? ? company.funding : nil,
      'countriesDeployed' => nil, #not part of initial launch
      'countryHq' => {
        'streetAddress' => company.present? ? company.street_address : nil,
        'city' => company.present? ? company.city : nil,
        'zipCode' => company.present? ? company.zip_code : nil,
        'state' => company.present? ? company.state : nil,
        'country' => company.present? ? company.country : nil
      },
      'downloads' => newest_download_snapshot.present? ? newest_download_snapshot.downloads : nil,
      'lastUpdated' => newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
      'updateFreq' => nil, 
      'appIcon' => {
        'large' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_350x350 : nil,
        'small' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
      },
      'companyWebsites' => ios_app.get_website_urls, #this is an array
      'appIdentifier' => ios_app.id
    }
    render json: app_json
  end
  
  def get_company
    
  end
  
  def app_info
    
  end
end
