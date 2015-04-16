class ApiController < ApplicationController
  
  skip_before_filter  :verify_authenticity_token
  
  def filter_ios_apps
    app_filters = params[:app]
    company_filters = params[:company]
    pageSize = params[:pageSize] || 50
    pageNum = params[:pageNum] || 1
    sort_by = params[:sortBy] || 'name'
    order_by = params[:orderBy] || 'ASC'
    
    #filter for companies
    company_results = FilterService.filter_companies(company_filters) if company_filters
    
    
    #filter for apps 
    app_results = FilterService.filter_ios_apps(app_filters) if app_filters
    
    #find apps and companies based on customKeywords, searching in the name
    if params[:customKeywords].present?
      companies_with_keywords = FilterService.companies_with_keywords(params[:customKeywords])
      company_results = company_filters.present? ? company_results.merge(companies_with_keywords) : companies_with_keywords

      apps_with_keywords = FilterService.apps_with_keywords(params[:customKeywords])
      app_results = app_filters.present? ? app_results.merge(apps_with_keywords) : apps_with_keywords
    end
        
    #join the apps the were found by app_results_filters, and the apps that belong to companies found by company_filters
    results = IosApp.where(id: nil).where("id IS NOT ?", nil) 
    if params[:company].present? && params[:app].present?
      company_apps = FilterService.apps_of_companies(company_results)
      results = app_results.merge(company_apps)
    elsif !params[:company].present? && params[:app].present?
      results = app_results
    elsif params[:company].present? && !params[:app].present?
      results = FilterService.apps_of_companies(company_results)
    elsif params[:customKeywords].present?
      app_result_ids = app_results.pluck(:id)
      company_app_result_ids = FilterService.apps_of_companies(company_results).pluck(:id)
      all_app_ids = (app_result_ids + company_app_result_ids).uniq
      results = IosApp.where(id: all_app_ids)
    end
    
    logger.info "results: #{results.map{|r| r.id}}"  
    results_json = []
    results.page(pageNum).per(pageSize).each do |app|
      li "constructing json hash for #{app.name}"
      company = app.get_company
      li "company: #{company.name} #{company.id}" if company.present?
      newest_snapshot = app.newest_ios_app_snapshot
      li "snapshot: #{newest_snapshot.name} #{newest_snapshot.id}" if newest_snapshot.present?
      app_hash = {
        app: {
          id: app.id, 
          name: newest_snapshot.present? ? newest_snapshot.name : nil,
          mobilePriority: app.mobile_priority,
          userBase: app.user_base,
          lastUpdated: newest_snapshot.present? ? newest_snapshot.released : nil,
          adSpend: app.ios_fb_ad_appearances.present?,
          categories: newest_snapshot.present? ? newest_snapshot.ios_app_categories.map{|c| c.name} : nil
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
