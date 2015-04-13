class ApiController < ApplicationController
  
  skip_before_filter  :verify_authenticity_token
  
  def filter_ios_apps
    @app_filters = params[:app]
    @company_filters = params[:company]
    @companies = nil
    @apps = nil
    
    #filter for companies
    if @company_filters.present?
      if @company_filters['fortuneRank'].present? #pass ranks as an integer
        @companies = Company.where("fortune_1000_rank <= #{@company_filters['fortuneRank'].to_s}")
      end
    
      if @company_filters['funding'].present? #start out with just 
        tmp =  Company.where("funding >= #{@company_filters['funding']}")
        @companies.blank? ? @companies = tmp : @companies.concat(tmp)
      end
    
      if @company_filters['countryHq'].present?
        relation_set = @companies.blank? ? Company : @companies
        @companies = relation_set.where("country = #{@company_filters['country']}")
      end
    end
    
    #filter for apps 
    if @app_filters.present?
      if @app_filters['mobilePriority'].present?
        
      end
    
      if @app_filters['adSpend'].present?
      
      end
    
      if @app_filters['downloads'].present?
        relation_set = @apps.blank? ? IosApp.includes(:ios_app_snapshots, :ios_app_download_snapshots, websites: :company) : @apps
        @apps = relation_set.joins(:ios_app_download_snapshots).where("downloads > #{@app_filters['downloads'].to_i}")
      end
    
      if @app_filters['lastUpdate'].present?

      end
    
      if @app_filters['categories'].present?
        relation_set = @apps.blank? ? IosApp.includes(:ios_app_snapshots, :ios_app_download_snapshots, websites: :company) : @apps
        @apps = relation_set.joins(:ios_app_categories).where("ios_app_categories.name IN (#{@app_filters.categories.join(',')})")
      end
      
    end
    
    #find apps and companies based on customKeywords, searching in the name
    if params[:customKeywords].present?
      keyword_query_array = []
      puts params[:customKeywords]
      for keyword in params[:customKeywords]
        keyword_query_array << "name LIKE \'%#{keyword}%\'"
      end
      keyword_query_string = keyword_query_array.join(' OR ')
      puts keyword_query_string
      
      if @company_filters.present?
        @companies = @companies.where(keyword_query_string)
      else
        @companies = Company.where(keyword_query_string)
      end
      
      if @app_filters.present?
        app_ids = @apps.pluck(:id)
        app_snapshots = IosAppSnapshot.where("ios_app_id IN (#{app_ids.join(',')})")
        snapshots_w_keyword = app_snapshots.where(keyword_query_string)
        snapshots_w_keyword_app_ids = snapshots_w_keyword_app_ids.pluck(:ios_app_id)
        @apps = @apps.where("id IN (#{snapshots_w_keyword_app_ids.join(',')})")
      else
        snapshots_w_keyword_app_ids = IosAppSnapshot.where(keyword_query_string).pluck(:ios_app_id)
        puts "app_snapshots: #{snapshots_w_keyword_app_ids.count}"
        @apps = IosApp.where("id IN (#{snapshots_w_keyword_app_ids.join(',')})")
      end
    end
    
    #join the apps the were found by @apps_filters, and the apps that belong to companies found by @company_filters
    results = nil
    if @company_filters.present? && @app_filters.present?
      company_ids = @companies.map{|c| c.id}
      company_website_ids = Website.where("company_id IN (#{company_ids.join(',')})").pluck(:id)  
      ios_app_website_ids = IosAppsWebsite.includes(website: :company).where("website_id IN (#{company_website_ids.join(',')})").pluck(:ios_app_id)    
      results = @apps.where("ios_apps.id IN (#{ios_app_website_ids.join(',')})")
    elsif @company_filters.blank? && @app_filters.present?
      results = @apps
    elsif @company_filters.present? && @app_filters.blank?
      company_ids = @companies.map{|c| c.id}
      company_website_ids = Website.where("company_id IN (#{company_ids.join(',')})").pluck(:id)  
      ios_app_website_ids = IosAppsWebsite.includes(website: :company).where("website_id IN (#{company_website_ids.join(',')})").pluck(:ios_app_id)
      results = IosApp.includes(:ios_app_snapshots, :ios_app_download_snapshots, websites: :company).where("ios_apps.id IN (#{ios_app_website_ids.join(',')})")
    elsif params[:customKeywords].present?
      company_website_ids = Website.where("company_id IN (#{@companies.pluck(:id).join(',')})").pluck(:id)
      company_app_ids = IosAppsWebsite.where("website_id IN (#{company_website_ids.join(',')})").pluck(:ios_app_id)
      company_app_ids = IosApp.where("id IN (#{company_app_ids.join(',')})").pluck(:id)
      app_ids = @apps.pluck(:id)
      results_ids = company_app_ids + app_ids
      results = IosApp.where("id IN (#{results_ids.join(',')})")
    else
      results = []
    end
    
    results_json = []
    results.each do |app|
      company = app.get_company
      newest_app_snapshot = app.get_newest_app_snapshot
      newest_download_snapshot = app.get_newest_download_snapshot
      app_hash = {
        app: {
          id: app.id, 
          name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
          countriesDeployed: nil,
          mobilePriority: nil,
          downloads: newest_download_snapshot.present? ? newest_download_snapshot.downloads : nil,
          lastUpdated: nil,
          adSpend: nil,
        },
        company: {
          id: company.present? ? company.id : nil,
          name: company.present? ? company.name : nil,
          fortuneRank: company.present? ? company.fortune_1000_rank : nil,
          funding: company.present? ? company.funding : nil,
          location: {
            streetAddress: company.present? ? company.street_address : nil,
            city: company.present? ? company.city : nil,
            zipCode: company.present? ? company.zip_code : nil,
            state: company.present? ? company.state : nil,
            country: company.present? ? company.country : nil
          }
        }
      }
      results_json << app_hash
    end
    
    render json: results_json
  end
  
  def filter_android_apps
    
  end
  
  # Get details of iOS app.
  # Input: appId (the key for the app in our database; not the appIdentifier)
  def get_ios_app
    appId = params['id']
    ios_app = IosApp.includes(:ios_app_snapshots, websites: :company).find(appId)
    company = ios_app.get_company #could be nil, if no websites, or websites don't have company
    newest_app_snapshot = ios_app.get_newest_app_snapshot
    newest_download_snapshot = ios_app.get_newest_download_snapshot
    app_json = {
      'id' => appId,
      'name' => newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      'mobilePriority' => nil, 
      'adSpend' => nil, 
      'countriesDeployed' => nil, #not part of initial launch
      'downloads' => newest_download_snapshot.present? ? newest_download_snapshot.downloads : nil,
      'lastUpdated' => newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
      'appIdentifier' => ios_app.id,
      'appIcon' => {
        'large' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_350x350 : nil,
        'small' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
      },
      'company' => {
        'name' => company.present? ? company.name : nil,
        'id' => company.present? ? company.id : nil,
        'fortuneRank' => company.present? ? company.fortune_1000_rank : nil, 
        'funding' => company.present? ? company.funding : nil,
        'websites' => ios_app.get_website_urls,
        'location' => {
          'streetAddress' => company.present? ? company.street_address : nil,
          'city' => company.present? ? company.city : nil,
          'zipCode' => company.present? ? company.zip_code : nil,
          'state' => company.present? ? company.state : nil,
          'country' => company.present? ? company.country : nil
        }
      }
    }
    render json: app_json
  end
  
  def get_android_app
    appId = params['id']
    android_app = AndroidApp.includes(:android_app_snapshots).find(appId)
    company = android_app.get_company
    newest_app_snapshot = android_app.get_newest_app_snapshot
    # newest_download_snapshot = android_app.get_newest_download_snapshot
    
    app_json = {
      id: appId,
      name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      mobilePriority: nil, 
      adSpend: nil, 
      countriesDeployed: nil, #not part of initial launch
      downloads: newest_app_snapshot.present? ? "#{newest_app_snapshot.downloads_min}-#{newest_app_snapshot.downloads_max}" : nil,
      lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
      appIdentifier: android_app.app_identifier,
      appIcon: {
        large: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_300x300 : nil
        # 'small' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
      },
      company: {
        name: company.present? ? company.name : nil,
        id: company.present? ? company.id : nil,
        fortuneRank: company.present? ? company.fortune_1000_rank : nil, 
        funding: company.present? ? company.funding : nil,
        websites: android_app.get_website_urls, #this is an array
        locatoin: {
          streetAddress: company.present? ? company.street_address : nil,
          city: company.present? ? company.city : nil,
          zipCode: company.present? ? company.zip_code : nil,
          state: company.present? ? company.state : nil,
          country: company.present? ? company.country : nil
        }
      }
    }
    render json: app_json
  end
  
  def get_company
    companyId = params['id']
    company = Company.includes(:websites).find(companyId)
    @company_json = {}
    if company.present?
      @company_json = {
        'id' => companyId,
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
        'iosApps' => company.get_ios_apps.map{|app| app.id},
        'androidApps' => company.get_android_apps.map{|app| app.id}
      }
    end
    render json: @company_json
  end

end
