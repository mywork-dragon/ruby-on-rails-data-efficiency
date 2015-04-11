class ApiController < ApplicationController
  
  skip_before_filter  :verify_authenticity_token
  
  def filter_ios_apps
    @app_filters = params[:app]
    @company_filters = params[:company]
    @companies
    @apps
    
    if @company_filters['fortune'].present? #pass ranks as an integer
      @companies = Company.where(:fortune_1000_rank > params['fortune'].to_i)
    end
    
    if @company_filters['funding'].present? #start out with just 
      relation_set = @companies.blank? ? Company : @companies
      @companies = relation_set.where(:funding > @company_filters['funding'].to_i)
    end
    
    if @company_filters['country'].present?
      relation_set = @companies.blank? ? Company : @companies
      @companies = relation_set.where(country: @company_filters['country'])
    end
    
    if @app_filters['mobilePriority'].present?
      
    end
    
    if @app_filters['adSpend'].present?
      
    end
    
    if @app_filters['countriesDeployed'].present?
      
    end
    
    if @app_filters['downloads'].present?
      relation_set = @apps.blank? ? IosApp : @apps
      @apps = relation_set.where(:downloads > @app_filters['downloads'].to_i)
    end
    
    if @app_filters['lastUpdate'].present?
      relation_set = @apps.blank? ? IosApp : @apps
    end
    
    if @app_filters['updateFrequency'].present?
      
    end
    

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
    # newest_download_snapshot = android_app.get_newest_download_snapshot
    
    app_json = {
      'appId' => appId,
      'appName' => newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      'company' => {
        'name' => company.present? ? company.name : nil,
        'id' => company.present? ? company.id : nil,
        'fortuneRank' => company.present? ? company.fortune_1000_rank : nil, 
        'funding' => company.present? ? company.funding : nil,
        'websites' => android_app.get_website_urls, #this is an array
        'location' => {
          'streetAddress' => company.present? ? company.street_address : nil,
          'city' => company.present? ? company.city : nil,
          'zipCode' => company.present? ? company.zip_code : nil,
          'state' => company.present? ? company.state : nil,
          'country' => company.present? ? company.country : nil
        }
      },
      'mobilePriority' => nil, 
      'adSpend' => nil, 
      'countriesDeployed' => nil, #not part of initial launch
      'downloads' => newest_app_snapshot.present? ? "#{newest_app_snapshot.downloads_min}-#{newest_app_snapshot.downloads_max}" : nil,
      'lastUpdated' => newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
      'updateFreq' => nil, 
      'appIcon' => {
        'large' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_300x300 : nil
        # 'small' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
      },
      'appIdentifier' => android_app.id
    }
    render json: app_json
  end
  
  def get_company
    companyId = params['companyId']
    company = Company.includes(:websites).find(companyId)
    @company_json = {}
    if company.present?
      @company_json = {
        'companyId' => companyId,
        'websites' => company.websites.to_a.map{|w| w.url},
        'funding' => company.funding,
        'location' => {
          'streetAddress' => company.street_address,
          'city' => company.city,
          'zipCode' => company.zip_code,
          'state' => company.state,
          'country' => company.country
        },
        'fortuneRank' => company.fortune_1000_rank,
        'ios_apps' => company.get_ios_apps.map{|app| app.id},
        'android_apps' => company.get_android_apps.map{|app| app.id}
      }
    end
    render json: @company_json
  end

end
