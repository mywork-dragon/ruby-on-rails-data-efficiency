class ApiController < ApplicationController
  
  skip_before_filter  :verify_authenticity_token
  
  #before_action :set_current_user, :authenticate_request #add this back later to verify every request -- jlew
  
  # before_filter :disable_cors
  #
  # def disable_cors
  #   puts "blah"
  #   headers['Access-Control-Allow-Origin'] = '*'
  #   headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
  #   headers['Access-Control-Request-Method'] = '*'
  #   headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  # end
  
  def download_fortune_1000_csv
    apps = IosApp.includes(:newest_ios_app_snapshot, websites: :company).joins(websites: :company).where('companies.fortune_1000_rank <= ?', 1000)
    puts apps.count
    f1000_csv = CSV.generate do |csv|
      csv << ['App ID', 'App Name', 'Company Name', 'Company ID', 'Support URL', 'Seller URL', 'Website URLs', 'Website IDs']
      apps.each do |app|
        if app.newest_ios_app_snapshot.present? && app.get_company.present?
          row = [app.id, app.newest_ios_app_snapshot.name, app.get_company.name, app.get_company.id, app.newest_ios_app_snapshot.support_url, app.newest_ios_app_snapshot.support_url, app.newest_ios_app_snapshot.seller_url, app.websites.map{|w| w.url}.join(', '), app.websites.map{|w| w.id}]
          csv << row
        end
      end
    end
    # puts f1000_csv
    # render send_data: f1000_csv
    # return f1000_csv
    respond_to do |format|
      format.csv { send_data f1000_csv }
    end
  end
  
  def filter_ios_apps_old
    app_filters = params[:app]
    company_filters = params[:company]
    pageSize = params[:pageSize].present? ? params[:pageSize].to_i : 50
    pageNum = params[:pageNum].present? ? params[:pageNum].to_i : 1
    sort_by = params[:sortBy] || 'appName'
    order_by = params[:orderBy] || 'ASC'
    
    #filter for companies
    queries = []
    queries << "includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company).joins(:newest_ios_app_snapshot).where('ios_app_snapshots.name IS NOT null')"
    
    queries << FilterService.ios_app_keywords_query(params[:customKeywords]) if params[:customKeywords].present?
    
    if company_filters.present?
      queries.concat(FilterService.company_ios_apps_query(company_filters)) if company_filters.present?
    else
      queries << "joins(websites: :company)"
    end
    
    queries.concat(FilterService.ios_apps_query(app_filters)) if app_filters.present?
    
    # queries << FilterService.ios_sort_order_query(sort_by, order_by)
    
    query = queries.join('.')
    query = "self." + query + ".group('ios_apps.id')"
    # li "query right before count: #{query}"
    
    results_count = IosApp.instance_eval("#{query}.count.length")
    # results_count = 5e6 #dummy the count
    # li "results_count: #{results_count}"
    
    query += ".limit(#{pageSize}).offset(#{(pageNum-1) * pageSize})"
    query += ".#{FilterService.ios_sort_order_query(sort_by, order_by)}"
    # query += ".#{order_query}"
    # li "query right before full eval: #{query}"
    results = IosApp.instance_eval(query)
    # li "FINISHED FULL EVAL TO GET RESULTS"
    # li "#{results.to_a.map{|r| r.id}}"
    # li "RESULTS CLASS: #{results.class}"
    # li "RESULTS COUNT: #{results.count.length}"
    results_json = []
    results.each do |app|
      # li "CREATING HASH FOR #{app.id}"
      company = app.get_company
      newest_snapshot = app.newest_ios_app_snapshot
      app_hash = {
        app: {
          id: app.id,
          name: newest_snapshot.present? ? newest_snapshot.name : nil,
          mobilePriority: app.mobile_priority,
          userBase: app.user_base,
          lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
          adSpend: app.ios_fb_ad_appearances.present?,
          categories: newest_snapshot.present? ? newest_snapshot.ios_app_categories.map{|c| c.name} : nil
        },
        company: {
          id: company.present? ? company.id : nil,
          name: company.present? ? company.name : nil,
          fortuneRank: company.present? ? company.fortune_1000_rank : nil
        }
      }
      # li "app_hash: #{app_hash}"
      # li "HASH: #{app_hash}"
      results_json << app_hash
      # li "results_json: #{results_json}"
    end
    # li "finished creating hashes"
    render json: {results: results_json, resultsCount: results_count}
    # render json: results_json
  end
  
  def filter_ios_apps
    app_filters = params[:app]
    company_filters = params[:company]
    page_size = params[:pageSize]
    page_num = params[:pageNum]
    sort_by = params[:sortBy] || 'appName'
    order_by = params[:orderBy] || 'ASC'
    custom_keywords = params[:customKeywords]
    
    filter_args = {
      app_filters: app_filters, 
      company_filters: company_filters, 
      custom_keywords: custom_keywords, 
      page_size: 50, 
      page_num: 1, 
      sort_by: 'appName',
       order_by: 'ASC'
    }
    
    filter_args.merge!({page_size: page_size}) if page_size
    filter_args.merge!({page_num: page_num}) if page_num
    
    filter_results = FilterService.filter_ios_apps(filter_args)
    
    results = filter_results[:results]
    results_count = filter_results[:results_count]
    
    results_json = []
    results.each do |app|
      # li "CREATING HASH FOR #{app.id}"
      company = app.get_company
      newest_snapshot = app.newest_ios_app_snapshot
      app_hash = {
        app: {
          id: app.id,
          name: newest_snapshot.present? ? newest_snapshot.name : nil,
          mobilePriority: app.mobile_priority,
          userBase: app.user_base,
          lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
          adSpend: app.ios_fb_ad_appearances.present?,
          categories: newest_snapshot.present? ? newest_snapshot.ios_app_categories.map{|c| c.name} : nil
        },
        company: {
          id: company.present? ? company.id : nil,
          name: company.present? ? company.name : nil,
          fortuneRank: company.present? ? company.fortune_1000_rank : nil
        }
      }
      # li "app_hash: #{app_hash}"
      # li "HASH: #{app_hash}"
      results_json << app_hash
      # li "results_json: #{results_json}"
    end
    
    render json: {results: results_json, resultsCount: results_count}
  end
  
  def filter_android_apps
    app_filters = params[:app]
    company_filters = params[:company]
    page_size = params[:pageSize]
    page_num = params[:pageNum]
    sort_by = params[:sortBy] || 'appName'
    order_by = params[:orderBy] || 'ASC'
    custom_keywords = params[:customKeywords]
    
    filter_args = {
      app_filters: app_filters, 
      company_filters: company_filters, 
      custom_keywords: custom_keywords, 
      page_size: 50, 
      page_num: 1, 
      sort_by: 'appName',
       order_by: 'ASC'
    }
    
    filter_args.merge!({page_size: page_size}) if page_size
    filter_args.merge!({page_num: page_num}) if page_num
    
    filter_results = FilterService.filter_android_apps(filter_args)
    
    results = filter_results[:results]
    results_count = filter_results[:results_count]
    
    results_json = []
    results.each do |app|
      company = app.get_company
      newest_snapshot = app.newest_android_app_snapshot
      app_hash = {
        app: {
          id: app.id,
          name: newest_snapshot.present? ? newest_snapshot.name : nil,
          mobilePriority: app.mobile_priority,
          userBase: app.user_base,
          lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
          adSpend: app.android_fb_ad_appearances.present?,
          categories: newest_snapshot.present? ? newest_snapshot.android_app_categories.map{|c| c.name} : nil
        },
        company: {
          id: company.present? ? company.id : nil,
          name: company.present? ? company.name : nil,
          fortuneRank: company.present? ? company.fortune_1000_rank : nil
        }
      }
      results_json << app_hash
    end
    
    render json: {results: results_json, resultsCount: results_count}
  end
  
  # Get details of iOS app.
  # Input: appId (the key for the app in our database; not the appIdentifier)
  def get_ios_app
    appId = params['id']
    ios_app = IosApp.includes(:ios_app_snapshots, websites: :company).find(appId)
    company = ios_app.get_company #could be nil, if no websites, or websites don't have company
    newest_app_snapshot = ios_app.newest_ios_app_snapshot
    newest_download_snapshot = ios_app.get_newest_download_snapshot
    app_json = {
      id: appId,
      name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      mobilePriority: ios_app.mobile_priority, 
      adSpend: ios_app.ios_fb_ad_appearances.present?, 
      countriesDeployed: nil, #not part of initial launch
      # downloads: newest_download_snapshot.present? ? newest_download_snapshot.downloads : nil,
      userBase: ios_app.user_base,
      lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released.to_s : nil,
      appIdentifier: ios_app.app_identifier,
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
    newest_app_snapshot = android_app.newest_android_app_snapshot
    
    app_json = {
      id: appId,
      name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      mobilePriority: android_app.mobile_priority, 
      adSpend: android_app.android_fb_ad_appearances.present?, 
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
  
  def get_company
    companyId = params['id']
    company = Company.includes(websites: {ios_apps: :newest_ios_app_snapshot}).find(companyId)
    @company_json = {}
    if company.present?
      @company_json = {
        id: companyId,
        name: company.name,
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
        iosApps: company.get_ios_apps.map{|app| {
          id: app.id,
          name: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.name : nil,
          mobilePriority: app.mobile_priority,
          adSpend: app.ios_fb_ad_appearances.present?,
          userBase: app.user_base,
          lastUpdated: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.released.to_s : nil,
          appIdentifier: app.app_identifier,
          appIcon: {
            large: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.icon_url_350x350 : nil,
            small: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.icon_url_175x175 : nil
          }
        }},
        androidApps: company.get_android_apps.map{|app| {
          id: app.id,
          name: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.name : nil,
          mobilePriority: app.mobile_priority,
          adSpend: app.android_fb_ad_appearances.present?,
          userBase: app.user_base,
          lastUpdated: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.released.to_s : nil,
          appIdentifier: app.app_identifier,
          appIcon: {
            large: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.icon_url_300x300 : nil
          }
        }}
      }
    end
    render json: @company_json
  end

  def get_ios_categories
    render json: IosAppCategory.select(:name).joins(:ios_app_categories_snapshots).group('ios_app_categories.id').where('ios_app_categories.name <> "Category:"').order('name asc').to_a.map{|cat| cat.name}
  end
  
  def get_android_categories
    render json: AndroidAppCategory.select(:name).joins(:android_app_categories_snapshots).group('android_app_categories.id').where('android_app_categories.name <> "Category:"').order('name asc').to_a.map{|cat| cat.name}
  end

end
