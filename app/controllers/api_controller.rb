class ApiController < ApplicationController
  
  skip_before_filter  :verify_authenticity_token
  
  # before_filter :disable_cors
  #
  # def disable_cors
  #   puts "blah"
  #   headers['Access-Control-Allow-Origin'] = '*'
  #   headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
  #   headers['Access-Control-Request-Method'] = '*'
  #   headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  # end
  
  
  def filter_ios_apps
    app_filters = params[:app]
    company_filters = params[:company]
    pageSize = params[:pageSize].present? ? params[:pageSize].to_i : 50
    pageNum = params[:pageNum].present? ? params[:pageNum].to_i : 1
    sort_by = params[:sortBy] || 'appName'
    order_by = params[:orderBy] || 'ASC'
    
    #filter for companies
    queries = []
    queries << "includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company)"

    queries.concat(FilterService.company_apps_query(company_filters)) if company_filters.present?

    queries.concat(FilterService.apps_query(app_filters)) if app_filters.present?

    queries << FilterService.app_keywords_query(params[:customKeywords]) if params[:customKeywords].present?
    
    queries << FilterService.sort_order_query(sort_by, order_by)
    
    query = queries.join('.')
    results = IosApp.instance_eval("self.#{query}.limit(#{pageSize}).offset(#{(pageNum-1) * pageSize})")
    results_json = []
    results.each do |app|
      company = app.get_company
      newest_snapshot = app.newest_ios_app_snapshot
      app_hash = {
        app: {
          id: app.id,
          name: newest_snapshot.present? ? newest_snapshot.name : nil,
          mobilePriority: app.mobile_priority,
          userBase: app.user_base,
          lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
          adSpend: app.ios_fb_ad_appearances.count,
          categories: newest_snapshot.present? ? newest_snapshot.ios_app_categories.map{|c| c.name} : nil
        },
        company: {
          id: company.present? ? company.id : nil,
          name: company.present? ? company.name : nil,
          fortuneRank: company.present? ? company.fortune_1000_rank : nil
        }
      }
      # li "app_hash: #{app_hash}"
      results_json << app_hash
      # li "results_json: #{results_json}"
    end
    render json: results_json
  end
  
  def filter_android_apps
    app_filters = params[:app]
    company_filters = params[:company]
    pageSize = params[:pageSize] || 50
    pageNum = params[:pageNum] || 1
    sort_by = params[:sortBy] || 'name'
    order_by = params[:orderBy] || 'ASC'
    companies_filtered = false
    
    
    
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
      id: appId,
      name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      mobilePriority: nil, 
      adSpend: nil, 
      countriesDeployed: nil, #not part of initial launch
      downloads: newest_download_snapshot.present? ? newest_download_snapshot.downloads : nil,
      lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released.to_s : nil,
      appIdentifier: ios_app.id,
      appIcon: {
        large: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_350x350 : nil,
        small: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
      },
      company: {
        name: company.present? ? company.name : nil,
        id: company.present? ? company.id : nil,
        fortuneRank: company.present? ? company.fortune_1000_rank : nil, 
        funding: company.present? ? company.funding : nil,
        websites: ios_app.get_website_urls,
        location: {
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
  
  def get_android_app
    appId = params['id']
    android_app = AndroidApp.includes(:android_app_snapshots).find(appId)
    company = android_app.get_company
    newest_app_snapshot = android_app.get_newest_app_snapshot
    # newest_download_snapshot = android_app.get_newest_download_snapshot
    
    app_json = {
      id: appId,
      name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      mobilePriority: app.mobile_priority, 
      adSpend: app.ios_fb_ad_appearances.present?, 
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
        id: companyId,
        websites: company.websites.to_a.map{|w| w.url},
        funding: company.funding,
        location: {
          streetAddress: company.street_address,
          city: company.city,
          zipCode: company.zip_code,
          state: company.state,
          country: company.country
        },
        fortuneRank: company.fortune_1000_rank,
        iosApps: company.get_ios_apps.map{|app| app.id},
        androidApps: company.get_android_apps.map{|app| app.id}
      }
    end
    render json: @company_json
  end

end
