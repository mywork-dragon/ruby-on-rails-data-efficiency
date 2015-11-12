# This is our internal API that talks to the frontend
class ApiController < ApplicationController
  
  skip_before_filter  :verify_authenticity_token

  before_action :set_current_user, :authenticate_request
  
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
  
  def filter_ios_apps
    
    li 'filter_ios_apps'
    
    app_filters = JSON.parse(params[:app])
    company_filters = JSON.parse(params[:company])
    # app_filters = params[:app]
    # company_filters = params[:company]
    page_size = params[:pageSize]
    page_num = params[:pageNum]
    sort_by = params[:sortBy]
    order_by = params[:orderBy]
    custom_keywords = JSON.parse(params[:custom])['customKeywords']
    # custom_keywords = params[:custom][:customKeywords]

    company_filters.has_key?('fortuneRank') ? company_filters['fortuneRank'] = company_filters['fortuneRank'].to_i : nil
    app_filters.has_key?('updatedDaysAgo') ? app_filters['updatedDaysAgo'] = app_filters['updatedDaysAgo'].to_i : nil

    filter_args = {
      app_filters: app_filters, 
      company_filters: company_filters, 
      custom_keywords: custom_keywords, 
      page_size: (page_size.blank? ? nil : page_size.to_i), 
      page_num: (page_num.blank? ? nil : page_num.to_i), 
      sort_by: sort_by,
      order_by: order_by
    }
    
    filter_args.delete_if{ |k, v| v.nil? }

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
          seller: newest_snapshot.present? ? newest_snapshot.seller : nil,
          type: 'IosApp',
          supportDesk: newest_snapshot.present? ? newest_snapshot.support_url : nil,
          categories: newest_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: newest_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name} : nil,
          appIcon: {
              large: newest_snapshot.present? ? newest_snapshot.icon_url_350x350 : nil,
              small: newest_snapshot.present? ? newest_snapshot.icon_url_175x175 : nil
          }
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
    
    render json: {results: results_json, resultsCount: results_count, pageNum: page_num}
  end
  
  def filter_android_apps
    app_filters = JSON.parse(params[:app])
    puts "###########"
    puts app_filters
    company_filters = JSON.parse(params[:company])
    page_size = params[:pageSize]
    page_num = params[:pageNum]
    sort_by = params[:sortBy]
    order_by = params[:orderBy]
    custom_keywords = JSON.parse(params[:custom])['customKeywords']

    company_filters.has_key?('fortuneRank') ? company_filters['fortuneRank'] = company_filters['fortuneRank'].to_i : nil
    app_filters.has_key?('updatedDaysAgo') ? app_filters['updatedDaysAgo'] = app_filters['updatedDaysAgo'].to_i : nil
    
    filter_args = {
      app_filters: app_filters, 
      company_filters: company_filters, 
      custom_keywords: custom_keywords, 
      page_size: (page_size.blank? ? nil : page_size.to_i), 
      page_num: (page_num.blank? ? nil : page_num.to_i), 
      sort_by: sort_by,
      order_by: order_by
    }
    
    filter_args.delete_if{ |k, v| v.nil? }

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
          seller: newest_snapshot.present? ? newest_snapshot.seller : nil,
          type: 'AndroidApp',
          supportDesk: newest_snapshot.present? ? newest_snapshot.seller_url : nil,
          categories: newest_snapshot.present? ? newest_snapshot.android_app_categories.map{|c| c.name} : nil,
          appIcon: {
              large: newest_snapshot.present? ? newest_snapshot.icon_url_300x300 : nil
              # 'small' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
          }
        },
        company: {
          id: company.present? ? company.id : nil,
          name: company.present? ? company.name : nil,
          fortuneRank: company.present? ? company.fortune_1000_rank : nil
        }
      }
      results_json << app_hash
    end
    
    render json: {results: results_json, resultsCount: results_count, pageNum: page_num}
  end
  
  # Get details of iOS app.
  # Input: appId (the key for the app in our database; not the appIdentifier)
  def get_ios_app
    appId = params['id']
    ios_app = IosApp.find(appId)
    company = ios_app.get_company #could be nil, if no websites, or websites don't have company
    newest_app_snapshot = ios_app.newest_ios_app_snapshot
    newest_download_snapshot = ios_app.get_newest_download_snapshot
    app_json = {
      id: appId,
      name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
      appStoreId: newest_app_snapshot.present? ? newest_app_snapshot.developer_app_store_identifier : nil,
      price: newest_app_snapshot.present? ? newest_app_snapshot.price : nil,
      releaseDate: newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
      size: newest_app_snapshot.present? ? newest_app_snapshot.size : nil,
      requiredIosVersion: newest_app_snapshot.present? ? newest_app_snapshot.required_ios_version : nil,
      recommendedAge: newest_app_snapshot.present? ? newest_app_snapshot.recommended_age : nil,
      description: newest_app_snapshot.present? ? newest_app_snapshot.description : nil,
      categories: newest_app_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: newest_app_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name} : nil,
      currentVersion: newest_app_snapshot.present? ? newest_app_snapshot.version : nil,
      currentVersionDescription: newest_app_snapshot.present? ? newest_app_snapshot.release_notes : nil,
      rating: newest_app_snapshot.present? ? newest_app_snapshot.ratings_all_stars : nil,
      ratingsCount: newest_app_snapshot.present? ? newest_app_snapshot.ratings_all_count : nil,
      mobilePriority: ios_app.mobile_priority, 
      adSpend: ios_app.ios_fb_ad_appearances.present?, 
      countriesDeployed: nil, #not part of initial launch
      # downloads: newest_download_snapshot.present? ? newest_download_snapshot.downloads : nil,
      userBase: ios_app.user_base,
      lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released.to_s : nil,
      appIdentifier: ios_app.app_identifier,
      supportDesk: newest_app_snapshot.present? ? newest_app_snapshot.support_url : nil,
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
    android_app = AndroidApp.find(appId)
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
      playStoreId: newest_app_snapshot.present? ? newest_app_snapshot.android_app_id : nil,
      price: newest_app_snapshot.present? ? newest_app_snapshot.price : nil,
      size: newest_app_snapshot.present? ? newest_app_snapshot.size : nil,
      requiredAndroidVersion: newest_app_snapshot.present? ? newest_app_snapshot.required_android_version : nil,
      contentRating: newest_app_snapshot.present? ? newest_app_snapshot.content_rating : nil,
      categories: newest_app_snapshot.present? ? newest_app_snapshot.android_app_categories.map{|c| c.name} : nil,
      description: newest_app_snapshot.present? ? newest_app_snapshot.description : nil,
      currentVersion: newest_app_snapshot.present? ? newest_app_snapshot.version : nil,
      downloadsMin: newest_app_snapshot.present? ? newest_app_snapshot.downloads_min : nil,
      downloadsMax: newest_app_snapshot.present? ? newest_app_snapshot.downloads_max : nil,
      inAppPurchaseMin: newest_app_snapshot.present? ? newest_app_snapshot.in_app_purchase_min : nil,
      inAppPurchaseMax: newest_app_snapshot.present? ? newest_app_snapshot.in_app_purchase_max : nil,
      rating: newest_app_snapshot.present? ? newest_app_snapshot.ratings_all_stars : nil,
      ratingsCount: newest_app_snapshot.present? ? newest_app_snapshot.ratings_all_count : nil,
      appIdentifier: android_app.app_identifier,
      supportDesk: newest_app_snapshot.present? ? newest_app_snapshot.seller_url : nil,
      displayStatus: android_app.display_type,
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
          type: 'IosApp',
          mobilePriority: app.mobile_priority,
          adSpend: app.ios_fb_ad_appearances.present?,
          userBase: app.user_base,
          categories: app.newest_ios_app_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: app.newest_ios_app_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name} : nil,
          lastUpdated: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.released.to_s : nil,
          appIdentifier: app.app_identifier,
          supportDesk: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.support_url : nil,
          appIcon: {
            large: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.icon_url_350x350 : nil,
            small: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.icon_url_175x175 : nil
          }
        }},
        androidApps: company.get_android_apps.map{|app| {
          id: app.id,
          name: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.name : nil,
          type: 'AndroidApp',
          mobilePriority: app.mobile_priority,
          adSpend: app.android_fb_ad_appearances.present?,
          userBase: app.user_base,
          categories: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.android_app_categories.map{|c| c.name} : nil,
          lastUpdated: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.released.to_s : nil,
          appIdentifier: app.app_identifier,
          supportDesk: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.seller_url : nil,
          appIcon: {
            large: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.icon_url_300x300 : nil
          }
        }}
      }
    end
    render json: @company_json
  end

  def get_ios_categories
    # IosAppCategory.select(:name).joins(:ios_app_categories_snapshots).group('ios_app_categories.id').where('ios_app_categories.name <> "Category:"').order('name asc').to_a.map{|cat| cat.name}
    categories = [
      'Books',
      'Business',
      'Catalogs',
      'Education',
      'Entertainment',
      'Finance',
      'Food & Drink',
      'Games',
      'Health & Fitness',
      # 'Kids',
      'Lifestyle',
      # 'Magazines & Newspapers',
      'Medical',
      'Music',
      'Navigation',
      'News',
      'Photo & Video',
      'Productivity',
      'Reference',
      'Social Networking',
      'Sports',
      'Travel',
      'Utilities',
      'Weather'
    ]
    render json: categories
  end
  
  def get_android_categories
    # AndroidAppCategory.select(:name).joins(:android_app_categories_snapshots).group('android_app_categories.id').where('android_app_categories.name <> "Category:"').order('name asc').to_a.map{|cat| cat.name}
    categories = [
      'Books & Reference',
      'Business',
      'Comics',
      'Communication',
      'Education',
      'Entertainment',
      'Family',
      'Finance',
      'Games',
      'Health & Fitness',
      'Libraries & Demo',
      'Lifestyle',
      'Media & Video',
      'Medical',
      'Music & Audio',
      'News & Magazines',
      'Personalization',
      'Photography',
      'Productivity',
      'Shopping',
      'Social',
      'Sports',
      'Tools',
      'Transportation',
      'Travel & Local',
      'Weather'
    ]
    render json: categories
  end

  def get_lists
    render json: User.find(decoded_auth_token[:user_id]).lists
  end

  # Get a list, given a user_id and list_id
  def get_list
    user_id = decoded_auth_token[:user_id]
    list_id = params['listId']


    if ListsUser.where(user_id: user_id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    list = List.find(list_id)

    ios_apps = list.ios_apps
    android_apps = list.android_apps

    results_json = []

    ios_apps.each do |app|
      # li "CREATING HASH FOR #{app.id}"
      company = app.get_company
      newest_snapshot = app.newest_ios_app_snapshot

      app_hash = {
          app: {
              id: app.id,
              name: newest_snapshot.present? ? newest_snapshot.name : nil,
              type: 'IosApp',
              seller: newest_snapshot.present? ? newest_snapshot.seller : nil,
              mobilePriority: app.mobile_priority,
              userBase: app.user_base,
              lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
              adSpend: app.ios_fb_ad_appearances.present?,
              categories: newest_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: newest_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name} : nil,
              supportDesk: newest_snapshot.present? ? newest_snapshot.support_url : nil,
              appIcon: {
                  large: newest_snapshot.present? ? newest_snapshot.icon_url_350x350 : nil,
                  small: newest_snapshot.present? ? newest_snapshot.icon_url_175x175 : nil
              }
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

    android_apps.each do |app|
      company = app.get_company
      newest_snapshot = app.newest_android_app_snapshot
      app_hash = {
          app: {
              id: app.id,
              name: newest_snapshot.present? ? newest_snapshot.name : nil,
              type: 'AndroidApp',
              seller: newest_snapshot.present? ? newest_snapshot.seller : nil,
              mobilePriority: app.mobile_priority,
              userBase: app.user_base,
              lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
              adSpend: app.android_fb_ad_appearances.present?,
              categories: newest_snapshot.present? ? newest_snapshot.android_app_categories.map{|c| c.name} : nil,
              supportDesk: newest_snapshot.present? ? newest_snapshot.seller_url : nil,
              appIcon: {
                  large: newest_snapshot.present? ? newest_snapshot.icon_url_300x300 : nil
                  # 'small' => newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
              }
          },
          company: {
              id: company.present? ? company.id : nil,
              name: company.present? ? company.name : nil,
              fortuneRank: company.present? ? company.fortune_1000_rank : nil
          }
      }
      results_json << app_hash
    end

    # render json: '{"resultsCount": 0, "currentList": "listName", "results":[{"app":{"id":62,"name":"Alpha","mobilePriority":"high","userBase":"moderate","lastUpdated":"2015-02-21","adSpend":true,"categories":[]},"company":{"id":391,"name":"Parisian, Satterfield and Koepp","fortuneRank":391}}]}'
    render json: {:resultsCount => results_json.count, :currentList => list_id, :results => results_json} #User.find(decoded_auth_token[:user_id]).lists.find(params['listId']).android_apps
  end

  def export_list_to_csv

    user = User.find(decoded_auth_token[:user_id])
    can_view_support_desk = user.account_id.nil? ? false : Account.find(user.account_id).can_view_support_desk

    list_id = params['listId']
    list = List.find(list_id)

    ios_apps = list.ios_apps
    android_apps = list.android_apps
    apps = []

    header = ['MightySignal App ID', 'App Name', 'App Type', 'Mobile Priority', 'User Base', 'Last Updated', 'Ad Spend', 'Categories', 'MightySignal Company ID', 'Company Name', 'Fortune Rank', 'Company Website(s)', 'MightySignal App Page', 'MightySignal Company Page']
    can_view_support_desk ? header.push('Support URL') : nil

    ios_apps.each do |app|
      # li "CREATING HASH FOR #{app.id}"
      company = app.get_company
      newest_snapshot = app.newest_ios_app_snapshot

      app_hash = [
          app.id,
          newest_snapshot.present? ? newest_snapshot.name : nil,
          'IosApp',
          app.mobile_priority,
          app.user_base,
          newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
          app.ios_fb_ad_appearances.present?,
          newest_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: newest_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name}.join(", ") : nil,
          company.present? ? company.id : nil,
          company.present? ? company.name : nil,
          company.present? ? company.fortune_1000_rank : nil,
          app.get_website_urls.join(", "),
          'http://www.mightysignal.com/app/app#/app/ios/' + app.id.to_s,
          company.present? ? 'http://www.mightysignal.com/app/app#/company/' + company.id.to_s : nil,
          can_view_support_desk && newest_snapshot.present? ? newest_snapshot.support_url : nil

      ]

      apps << app_hash

    end

    android_apps.each do |app|
      company = app.get_company
      newest_snapshot = app.newest_android_app_snapshot

      app_hash = [
          app.id,
          newest_snapshot.present? ? newest_snapshot.name : nil,
          'AndroidApp',
          app.mobile_priority,
          app.user_base,
          newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
          app.android_fb_ad_appearances.present?,
          newest_snapshot.present? ? newest_snapshot.android_app_categories.map{|c| c.name}.join(", ") : nil,
          company.present? ? company.id : nil,
          company.present? ? company.name : nil,
          company.present? ? company.fortune_1000_rank : nil,
          app.get_website_urls.join(", "),
          'http://www.mightysignal.com/app/app#/app/android/' + app.id.to_s,
          company.present? ? 'http://www.mightysignal.com/app/app#/company/' + company.id.to_s : nil

      ]

      apps << app_hash

    end

    list_csv = CSV.generate do |csv|
      csv << header
      apps.each do |app|
          csv << app
      end
    end

    send_data list_csv

  end

  def export_contacts_to_csv
    contacts = params['contacts']
    companyName = params['companyName']
    header = ['MightySignal ID', 'Company Name', 'Title', 'Full Name', 'First Name', 'Last Name', 'Email', 'LinkedIn']

    list_csv = CSV.generate do |csv|
      csv << header
      contacts.each do |contact|
        contacts_hash = [
            contact['clearBitId'],
            companyName,
            contact['title'],
            contact['fullName'],
            contact['givenName'],
            contact['familyName'],
            contact['email'],
            contact['linkedin']
        ]
        csv << contacts_hash
      end
    end

    send_data list_csv

  end

  def create_new_list

    authenticated_user = User.find(decoded_auth_token[:user_id])

    list_name = params['listName']

    render json: authenticated_user.lists.create(name: list_name)

    # render json: List.find(authenticated_user.id).find(list_name)

  end

  def add_to_list
    user_id = decoded_auth_token[:user_id]
    list_id = params['listId']
    apps = params['apps']
    app_platform = params['appPlatform']

    if ListsUser.where(user_id: user_id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    if app_platform == 'ios'
      listable_type = 'IosApp'
    else
      listable_type = 'AndroidApp'
    end

    apps.each { |app|
      if ListablesList.find_by(listable_id: app['id'], list_id: list_id, listable_type: listable_type).nil?
        ListablesList.create(listable_id: app['id'], list_id: list_id, listable_type: listable_type)
      end
    }

    render json: {:status => 'success'}
  end

  def add_mixed_to_list
    user_id = decoded_auth_token[:user_id]
    list_id = params['listId']
    apps = params['apps']

    if ListsUser.where(user_id: user_id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    apps.each { |app|
      if ListablesList.find_by(listable_id: app['id'], list_id: list_id, listable_type: app['type']).nil?
        ListablesList.create(listable_id: app['id'], list_id: list_id, listable_type: app['type'])
      end
    }

    render json: {:status => 'success'}
  end

  def delete_from_list
    user_id = decoded_auth_token[:user_id]
    list_id = params['listId']
    apps = params['apps']

    if ListsUser.where(user_id: user_id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    puts apps.each { |app| ListablesList.find_by(listable_id: app['id'], list_id: list_id, listable_type: app['type']).destroy }
    render json: {:status => 'success'}
  end

  def delete_list
    user_id = decoded_auth_token[:user_id]
    list_id = params['listId']

    if ListsUser.where(user_id: user_id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    List.find(list_id).destroy

    render json: {:status => 'success'}
  end

  def results
    render json: GoogleResults.search("something")
  end

  def user_tos_check
    render json: { :tos_accepted => User.find(decoded_auth_token[:user_id]).tos_accepted }
  end

  def user_tos_set

    tos_status = params['tos_accepted']

    if tos_status
      user = User.find(decoded_auth_token[:user_id])
      user.tos_accepted = true
      user.save
    end

    render json: { :tos_accepted => User.find(decoded_auth_token[:user_id]).tos_accepted }
  end

  def get_company_contacts

    company_websites = params['companyWebsites']
    filter = params['filter']
    contacts = []

    if company_websites.blank?
      render json: {:contacts => contacts}
      return
    else

      # takes up to five websites associated with company & creates array of clearbit_contacts objects
      company_websites.first(5).each do |url|

        # finds matching record in website table
        website = Website.find_by(url: url)

        # finds contact object for
        clearbit_contacts_for_website = website.blank? ? [] : ClearbitContact.where(website_id: website.id)

        # true if record is older than 60 days
        data_expired = clearbit_contacts_for_website.blank? ? false : clearbit_contacts_for_website.first.updated_at < 60.days.ago

        if !filter.blank? || clearbit_contacts_for_website.empty? || data_expired

          domain = UrlHelper.url_with_domain_only(url)

          clearbit_query = filter.blank? ? {'domain' => domain} : {'domain' => domain, 'title' => filter}

          puts "####"
          puts clearbit_query
          puts "####"

          get = HTTParty.get('https://prospector.clearbit.com/v1/people/search', headers: {'Authorization' => 'Bearer 229daf10e05c493613aa2159649d03b4'}, query: clearbit_query)
          new_clearbit_contacts = JSON.load(get.response.body)

          # delete old records (prevents duplicates)
          ClearbitContact.where(website_id: website.id).destroy_all if data_expired

          if new_clearbit_contacts.kind_of?(Array)

            new_clearbit_contacts.each do |contact|
              # add to results hash (to return to front end)

              contact_id = contact['id']
              contact_name = contact['name']
              if contact_name
                contact_given_name = contact_name['givenName']
                contact_family_name = contact_name['familyName']
                contact_full_name = contact_name['fullName']
              end
              contact_title = contact['title']
              contact_email = contact['email']
              contact_linkedin = contact['linkedin']

              contacts << {
                website_id: (website.present? ? website.id : nil),
                clearBitId: contact_id,
                givenName: contact_given_name,
                familyName: contact_family_name,
                fullName: contact_full_name,
                title: contact_title,
                email: contact_email,
                linkedin: contact_linkedin
              }

              # save as new records to DB
              if website
                clearbit_contact = ClearbitContact.create(website_id: website.id)
                previous_record = ClearbitContact.where(clearbit_id: contact_id)
                if previous_record.exists?
                  previous_record.destroy_all
                end
                if contact_id != nil
                  clearbit_contact.update(website_id: website.id, clearbit_id: contact_id, given_name: contact_given_name, family_name: contact_family_name, full_name: contact_full_name, title: contact_title, email: contact_email, linkedin: contact_linkedin)
                end
                clearbit_contact.save
              end
            end

          end

        # if record exists and is no more than 60 days old
        else

          clearbit_contacts_for_website.each do |clearbit_contact|
            # add to results hash (to return to front end)
            contacts << {
              website_id: website.id,
              clearBitId: clearbit_contact.id,
              givenName: clearbit_contact.given_name,
              familyName: clearbit_contact.family_name,
              fullName: clearbit_contact.full_name,
              title: clearbit_contact.title,
              email: clearbit_contact.email,
              linkedin: clearbit_contact.linkedin
            }
          end
        end
      end
      render json: {:contacts => contacts}
    end
  end


  def android_sdks_exist

    android_app_id = params['appId']

    aa = AndroidApp.find(android_app_id)

    updated, companies, error_code = nil

    price = aa.newest_android_app_snapshot.price.to_i

    if !price.zero?

      error_code = 4

    else

      companies, updated, error_code = get_sdks(android_app_id: android_app_id)

    end

    render json: sdk_hash(companies: companies, updated: updated, error_code: error_code, snap: aa.newest_apk_snapshot)

  end

  def scan_android_sdks

    android_app_id = params['appId']

    updated, companies, error_code = nil

    aa = AndroidApp.find(android_app_id)

    error_code = 1

    price = aa.newest_android_app_snapshot.price.to_i

    # if aa.taken_down?

    #   error_code = 2

    # els
    if !price.zero?

      error_code = 4

    else

      app_identifier = aa.app_identifier

      job_id, new_snap = download_apk(android_app_id, app_identifier)

      aa = AndroidApp.find(android_app_id)

      # new_snap = aa.newest_apk_snapshot

      # TestModel.create(string0: android_app_id, string1: new_snap.id, string2: new_snap.status) if new_snap.present?

      if new_snap.present? && new_snap.status == "success"

        scan_apk(aa.id, job_id)

        companies, updated, error_code = get_sdks(android_app_id: android_app_id)

      else

        apk_snap = ApkSnapshot.find_by_apk_snapshot_job_id(job_id)
      
        apk_snap.scan_status = ApkSnapshot.scan_statuses[:scan_failure]

        apk_snap.save

        error_code = 3
      
      end

    end

    render json: sdk_hash(companies: companies, updated: updated, error_code: error_code, snap: aa.newest_apk_snapshot)

  end

  def get_sdks(android_app_id:)

    updated, companies = nil

    error_code = 0

    aa = AndroidApp.find(android_app_id)

    if aa.newest_apk_snapshot.present?

      new_snap = aa.newest_apk_snapshot

      if new_snap.status == "success"

        updated = new_snap.updated_at

        companies = new_snap.android_sdk_companies

        # removed_companies = get_removed_companies(android_app: aa, companies: companies)

        # error_code = (companies.count.zero? && removed_companies.count.zero?) ? 1:0

        error_code = companies.count.zero? ? 1:0

      else

        error_code = 5

      end

    end

    return companies, updated, error_code

  end

  def get_removed_companies(android_app:, companies:)

    current_ids = companies.map(&:id)

    total_ids = []

    android_app.apk_snapshots.joins(:android_sdk_companies).each do |cos|

      cos_ids = cos.android_sdk_companies.map(&:id)

      total_ids = total_ids + cos_ids

    end

    AndroidSdkCompany.where(id: (total_ids.uniq - current_ids))

  end

  def sdk_hash(companies:, updated:, error_code:, snap:)

    main_hash = Hash.new

    installed_co_hash, installed_os_hash = form_hash(companies)

    # uninstalled_co_hash, uninstalled_os_hash = form_hash(removed_companies)

    # error_code = 1 if installed_co_hash.empty? && installed_os_hash.empty? && uninstalled_co_hash.empty? && uninstalled_os_hash.empty? && error_code.zero?

    error_code = 1 if installed_co_hash.empty? && installed_os_hash.empty? && error_code.zero? && snap.present?
    
    main_hash['installed_sdk_companies'] = installed_co_hash

    main_hash['installed_open_source_sdks'] = installed_os_hash

    main_hash['uninstalled_sdk_companies'] = {}

    main_hash['uninstalled_open_source_sdks'] = {}

    main_hash['updated'] = updated

    main_hash['error_code'] = error_code

    main_hash.to_json

  end

  def form_hash(companies)

    co_hash = Hash.new

    os_hash = Hash.new

    if companies.present?

      companies.each do |company|

        next if company.nil? || company.flagged

        main_company = company.parent_company_id.present? ? AndroidSdkCompany.find(company.parent_company_id) : company

        children = if company.parent_company_id.present?

          cc = company

          { 'name' => cc.name, 'website' => cc.website, 'favicon' => (cc.favicon.nil? && cc.open_source) ? 'https://assets-cdn.github.com/pinned-octocat.svg' : cc.favicon }

        else

          nil

        end

        if company.open_source

          if co_hash[main_company.name].blank? || company.parent_company_id.blank?

            os_hash[main_company.name] = { 'website' => main_company.website, 'favicon' => main_company.favicon, 'android_app_count' => main_company.android_apps.count, 'children' => [children].compact }

          else

            co_hash[main_company.name]['children'] << children if co_hash[main_company.name]['children'].exclude? children

          end

        else

          if co_hash[main_company.name].blank? || company.parent_company_id.blank?

            co_hash[main_company.name] = { 'website' => main_company.website, 'favicon' => main_company.favicon, 'android_app_count' => main_company.android_apps.count, 'children' => [children].compact }

          else

            co_hash[main_company.name]['children'] << children if co_hash[main_company.name]['children'].exclude? children

          end

        end

      end

    end

    co_hash = sort_hash(co_hash)

    os_hash = sort_hash(os_hash)

    return co_hash, os_hash

  end

  def sort_hash(hash)
    hash = hash.sort_by{ |k,v| -v['android_app_count'] }.to_h
  end

  def download_apk(android_app_id, app_identifier)

    job_id = ApkSnapshotJob.create!(notes: "SINGLE: #{app_identifier}").id

    batch = Sidekiq::Batch.new
    bid = batch.bid

    batch.jobs do
      ApkSnapshotServiceSingleWorker.perform_async(job_id, bid, android_app_id)
    end

    new_snap = nil

    360.times do

      sleep 0.25
      
      ss = ApkSnapshot.uncached{ ApkSnapshot.find_by_apk_snapshot_job_id(job_id) }

      if ss.present? && ss.status.present?

        if ss.status = "success"

          aa = ss.android_app

          if aa.newest_apk_snapshot.present? && aa.newest_apk_snapshot.id == ss.id

            new_snap = ss

            break

          end

        else

          break if ss.try == 3

        end

      end

    end

    return job_id, new_snap

  end

  def scan_apk(android_app_id, job_id)

    PackageSearchServiceSingleWorker.perform_async(android_app_id)

    360.times do

      sleep 0.25

      ss = ApkSnapshot.uncached{ ApkSnapshot.find_by_apk_snapshot_job_id(job_id) }

      break if ss.present? && ss.scan_status.present?
    end

  end

  def export_all_search_results_to_csv

  end

  def newest_apps_chart

    page_size = params[:pageSize]
    page_num = params[:pageNum]

    results = IosApp.where(released: Date.new(2015, 7, 24)..Date.new(2015, 7, 30))
    results_count = results.count

    results_json = []
    results.each do |app|
      # li "CREATING HASH FOR #{app.id}"
      company = app.get_company
      newest_snapshot = app.newest_ios_app_snapshot

      app_hash = {
          id: app.id,
          name: newest_snapshot.present? ? newest_snapshot.name : nil,
          mobilePriority: app.mobile_priority,
          userBase: app.user_base,
          releasedDate: app.released,
          lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
          adSpend: app.ios_fb_ad_appearances.present?,
          type: 'IosApp',
          supportDesk: newest_snapshot.present? ? newest_snapshot.support_url : nil,
          categories: newest_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: newest_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name} : nil,
          appIcon: {
              large: newest_snapshot.present? ? newest_snapshot.icon_url_350x350 : nil,
              small: newest_snapshot.present? ? newest_snapshot.icon_url_175x175 : nil
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

    render json: {results: results_json, resultsCount: results_count, pageNum: page_num}
  end

  def export_newest_apps_chart_to_csv

    apps = []

    # ---------------- iOS ----------------
    header = ['MightySignal App ID', 'iOS App ID', 'App Name', 'Company Name', 'Fortune Rank', 'Mobile Priority', 'Ad Spend', 'User Base', 'Categories', 'Released Date', 'Total Ratings']

    results = IosApp.includes(:ios_fb_ad_appearances, newest_ios_app_snapshot: :ios_app_categories, websites: :company).joins(:newest_ios_app_snapshot).where('ios_app_snapshots.name IS NOT null').where(mobile_priority: [0]).where(user_base: [0, 1]).joins(newest_ios_app_snapshot: {ios_app_categories_snapshots: :ios_app_category}).where('ios_app_categories.name IN (?) AND ios_app_categories_snapshots.kind = ?', ["Food & Drink", "Travel", "Lifestyle", "Sports", "Health & Fitness", "Entertainment", "Photo & Video"], 0).group('ios_apps.id').order('ios_app_snapshots.name ASC').to_a

    results_json = []
    results.each do |app|
      # li "CREATING HASH FOR #{app.id}"
      company = app.get_company
      newest_snapshot = app.newest_ios_app_snapshot

      app_hash = [
          app.id,
          app.app_identifier,
          newest_snapshot.present? ? newest_snapshot.name : nil,
          newest_snapshot.present? ? newest_snapshot.seller : nil,
          company.present? ? company.fortune_1000_rank : nil,
          app.mobile_priority,
          app.ios_fb_ad_appearances.present? ? 'Yes' : 'No',
          app.user_base,
          newest_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: newest_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name}.join(", ") : nil,
          app.released,
          newest_snapshot.present? ? newest_snapshot.ratings_all_count : nil
      ]

      apps << app_hash

    end

    # ---------------- ANDROID ----------------
=begin
    header = ['MightySignal App ID', 'Android App ID', 'App Name', 'Company Name', 'Fortune Rank', 'Mobile Priority', 'Ad Spend', 'User Base', 'Categories', 'Total Ratings', 'Min Downloads', 'Max Downloads']

    results = AndroidApp.includes(:android_fb_ad_appearances, newest_android_app_snapshot: :android_app_categories, websites: :company).joins(:newest_android_app_snapshot).where('android_app_snapshots.name IS NOT null').where(mobile_priority: [0]).where(user_base: [0, 1]).joins(newest_android_app_snapshot: {android_app_categories_snapshots: :android_app_category}).where('android_app_categories.name IN (?)', ["Travel & Local", "Lifestyle", "Sports", "Health & Fitness", "Entertainment", "Photography"]).group('android_apps.id').order('android_app_snapshots.name ASC').to_a

    results_json = []
    results.each do |app|
      # li "CREATING HASH FOR #{app.id}"
      company = app.get_company
      newest_snapshot = app.newest_android_app_snapshot

      # Android
      app_hash = [
          app.id,
          app.app_identifier,
          newest_snapshot.present? ? newest_snapshot.name : nil,
          newest_snapshot.present? ? newest_snapshot.seller : nil,
          company.present? ? company.fortune_1000_rank : nil,
          app.mobile_priority,
          app.android_fb_ad_appearances.present? ? 'Yes' : 'No',
          app.user_base,
          newest_snapshot.present? ? newest_snapshot.android_app_categories.map{|c| c.name}.join(', ') : nil,
          newest_snapshot.present? ? newest_snapshot.ratings_all_count : nil,
          newest_snapshot.present? ? newest_snapshot.downloads_min : nil,
          newest_snapshot.present? ? newest_snapshot.downloads_max : nil
      ]

      apps << app_hash

    end
=end

    list_csv = CSV.generate do |csv|
      csv << header
      apps.each do |app|
        csv << app
      end
    end

    send_data list_csv
  end

  def search_ios_apps
    query = params['query']
    page = !params['page'].nil? ? params['page'].to_i : 1
    num_per_page = !params['numPerPage'].nil? ? params['numPerPage'].to_i : 100

    result_ids = AppsIndex::IosApp.query(
        multi_match: {
            query: query,
            operator: 'and',
            fields: [:name, :seller_url, :seller],
            type: 'cross_fields',
            fuzziness: 1
        }
    ).boost_factor(
        3,
        filter: {
            range:{
                ratings_all: {
                    gte: 150000
                }
            }
        }
    ).boost_factor(
        2,
        filter: {
            range:{
                ratings_all: {
                    gte: 100000,
                    lt: 150000
                }
            }
        }
    ).limit(num_per_page).offset((page - 1) * num_per_page)

    total_apps_count = result_ids.total_count # the total number of potential results for query (independent of paging)
    result_ids = result_ids.map { |result| result.attributes["id"] }

    ios_apps = []
    result_ids.each{ |id| ios_apps << IosApp.find(id) }
    results_json = []

    ios_apps.each do |app|

      company = app.get_company
      newest_snapshot = app.newest_ios_app_snapshot

      app_hash = {
          app: {
              id: app.id,
              name: newest_snapshot.present? ? newest_snapshot.name : nil,
              type: 'IosApp',
              mobilePriority: app.mobile_priority,
              userBase: app.user_base,
              lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
              adSpend: app.ios_fb_ad_appearances.present?,
              categories: newest_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: newest_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name} : nil,
              supportDesk: newest_snapshot.present? ? newest_snapshot.support_url : nil,
              appIcon: {
                  large: newest_snapshot.present? ? newest_snapshot.icon_url_350x350 : nil,
                  small: newest_snapshot.present? ? newest_snapshot.icon_url_175x175 : nil
              },
              seller: newest_snapshot.present? ? newest_snapshot.seller : nil
          },
          company: {
              id: company.present? ? company.id : nil,
              name: company.present? ? company.name : nil,
              fortuneRank: company.present? ? company.fortune_1000_rank : nil
          }
      }
      results_json << app_hash
    end
    render json: {appData: results_json, totalAppsCount: total_apps_count, numPerPage: num_per_page, page: page}
  end

  def search_android_apps
    query = params['query']
    page = !params['page'].nil? ? params['page'].to_i : 1
    num_per_page = !params['numPerPage'].nil? ? params['numPerPage'].to_i : 100

    result_ids = AppsIndex::AndroidApp.query(
        multi_match: {
            query: query,
            operator: 'and',
            fields: [:name, :seller_url, :seller],
            type: 'cross_fields',
            fuzziness: 1
        }
    ).boost_factor(
        3,
        filter: {
            range:{
                ratings_all: {
                    gte: 1000000
                }
            }
        }
    ).boost_factor(
        2,
        filter: {
            range:{
                ratings_all: {
                    gte: 1000000,
                    lt: 140000
                }
            }
        }
    ).limit(num_per_page).offset((page - 1) * num_per_page)
    total_apps_count = result_ids.total_count # the total number of potential results for query (independent of paging)
    result_ids = result_ids.map { |result| result.attributes["id"] }

    android_apps = []
    result_ids.each{ |id| android_apps << AndroidApp.find(id) }
    results_json = []

    android_apps.each do |app|

      company = app.get_company
      newest_snapshot = app.newest_android_app_snapshot

      app_hash = {
          app: {
              id: app.id,
              name: newest_snapshot.present? ? newest_snapshot.name : nil,
              type: 'AndroidApp',
              mobilePriority: app.mobile_priority,
              userBase: app.user_base,
              lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
              adSpend: app.android_fb_ad_appearances.present?,
              downloadsMin: newest_snapshot.present? ? newest_snapshot.downloads_min : nil,
              downloadsMax: newest_snapshot.present? ? newest_snapshot.downloads_max : nil,
              categories: newest_snapshot.present? ? newest_snapshot.android_app_categories.map{|c| c.name} : nil,
              supportDesk: newest_snapshot.present? ? newest_snapshot.seller_url : nil,
              appIcon: {
                  large: newest_snapshot.present? ? newest_snapshot.icon_url_300x300 : nil
              },
              seller: newest_snapshot.present? ? newest_snapshot.seller : nil
          },
          company: {
              id: company.present? ? company.id : nil,
              name: company.present? ? company.name : nil,
              fortuneRank: company.present? ? company.fortune_1000_rank : nil
          }
      }
      results_json << app_hash
    end
    render json: {appData: results_json, totalAppsCount: total_apps_count, numPerPage: num_per_page, page: page}
  end

  def search_sdk
    query = params['query']
    page = !params['page'].nil? ? params['page'].to_i : 1
    num_per_page = !params['numPerPage'].nil? ? params['numPerPage'].to_i : 100
    sdks = []
    sdks << AndroidSdkCompany.find(1)

    total_apps_count = sdks.length

    results_json = []

    sdks.each do |sdk|

      app_hash = {
          sdk: {
              id: sdk.id,
              name: sdk.name,
              website: sdk.website,
              favicon: sdk.favicon,
              open_source: sdk.open_source,
              platform: 'android'
          }
      }
      results_json << app_hash
    end
    render json: {sdkData: results_json, totalAppsCount: total_apps_count, numPerPage: num_per_page, page: page}

  end

  # METHOD USED FOR CREATING CUSTOM CSVs (usually hooked up to export button in UI)
  def get_sdk
    sdk_id = params['id']
    sdk = AndroidSdkCompany.find(sdk_id)

    @sdk_json = {
        id: sdk.id,
        name: sdk.name,
        website: sdk.website,
        favicon: sdk.favicon,
        open_source: sdk.open_source,
        platform: 'android',
=begin
        iosApps: company.get_ios_apps.map{|app| {
            id: app.id,
            name: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.name : nil,
            type: 'IosApp',
            mobilePriority: app.mobile_priority,
            adSpend: app.ios_fb_ad_appearances.present?,
            userBase: app.user_base,
            categories: app.newest_ios_app_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: app.newest_ios_app_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name} : nil,
            lastUpdated: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.released.to_s : nil,
            appIdentifier: app.app_identifier,
            supportDesk: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.support_url : nil,
            appIcon: {
                large: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.icon_url_350x350 : nil,
                small: app.newest_ios_app_snapshot.present? ? app.newest_ios_app_snapshot.icon_url_175x175 : nil
            }
        }},
=end
        androidApps: sdk.android_apps.map{|app| {
            id: app.id,
            name: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.name : nil,
            type: 'AndroidApp',
            mobilePriority: app.mobile_priority,
            adSpend: app.android_fb_ad_appearances.present?,
            userBase: app.user_base,
            categories: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.android_app_categories.map{|c| c.name} : nil,
            lastUpdated: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.released.to_s : nil,
            appIdentifier: app.app_identifier,
            supportDesk: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.seller_url : nil,
            appIcon: {
                large: app.newest_android_app_snapshot.present? ? app.newest_android_app_snapshot.icon_url_300x300 : nil
            }
          }
        }
    }
    render json: @sdk_json
  end

  def get_sdk_autocomplete
    search_str = params['searchstr']

    # Logic for processing ElasticSearch search from params

    # Querying RDS for top x num of results

    render json: {
               searchParam: search_str,
               results: [
                   {id: 1, name: 'Example SDK', favicon: 'http://robohash.org/com.alpha322322300.png?size=300x300'},
                   {id: 2, name: 'Example SDK 2', favicon: 'http://robohash.org/com.biodex107107300.png?size=300x300'}
               ]
           }
  end

  def test_timeout
    sleep 65
    render json: {test: 'complete'}
  end

end
