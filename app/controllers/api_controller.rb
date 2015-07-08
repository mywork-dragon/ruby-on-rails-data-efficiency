# This is our internal API that talks to the frontend

class ApiController < ApplicationController
  
  skip_before_filter  :verify_authenticity_token

  #before_action :set_current_user, :authenticate_request
  
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
    
    app_filters = params[:app]
    company_filters = params[:company]
    page_size = params[:pageSize]
    page_num = params[:pageNum]
    sort_by = params[:sortBy]
    order_by = params[:orderBy]
    custom_keywords = params[:customKeywords]
    
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
    
    render json: {results: results_json, resultsCount: results_count}
  end
  
  def filter_android_apps
    app_filters = params[:app]
    company_filters = params[:company]
    page_size = params[:pageSize]
    page_num = params[:pageNum]
    sort_by = params[:sortBy]
    order_by = params[:orderBy]
    custom_keywords = params[:customKeywords]
    
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
    
    puts "filter_args: #{filter_args}"
    
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
    
    render json: {results: results_json, resultsCount: results_count}
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
              mobilePriority: app.mobile_priority,
              userBase: app.user_base,
              lastUpdated: newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
              adSpend: app.ios_fb_ad_appearances.present?,
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

    # render json: '{"resultsCount": 0, "currentList": "listName", "results":[{"app":{"id":62,"name":"Alpha","mobilePriority":"high","userBase":"moderate","lastUpdated":"2015-02-21","adSpend":true,"categories":[]},"company":{"id":391,"name":"Parisian, Satterfield and Koepp","fortuneRank":391}}]}'
    render json: {:resultsCount => results_json.count, :currentList => list_id, :results => results_json} #User.find(decoded_auth_token[:user_id]).lists.find(params['listId']).android_apps
  end

  def export_list_to_csv

    list_id = params['listId']

    list = List.find(list_id)

    ios_apps = list.ios_apps
    android_apps = list.android_apps
    apps = []

    header = ['MightySignal App ID', 'App Name', 'App Type', 'Mobile Priority', 'User Base', 'Last Updated', 'Ad Spend', 'Categories', 'MightySignal Company ID', 'Company Name', 'Fortune Rank', 'Company Website(s)']

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
          app.get_website_urls.join(", ")
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
          app.get_website_urls.join(", ")
      ]

      apps << app_hash

    end

    puts apps.inspect

    list_csv = CSV.generate do |csv|
      csv << header
      apps.each do |app|
          csv << app
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

    puts user_id
    puts apps.inspect
    puts list_id

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
    contacts = []

    if company_websites.blank?
      render json: {:contacts => contacts}
      return
    else
      
      puts "company_websites: #{company_websites}"

      # takes up to five websites associated with company & creates array of clearbit_contacts objects
      company_websites.first(5).each do |url|

        # finds matching record in website table
        website = Website.find_by(url: url)

        # finds contact object for
        clearbit_contacts_for_website = website.blank? ? [] : ClearbitContact.where(website_id: website.id)

        if clearbit_contacts_for_website.empty? || clearbit_contacts_for_website.first.updated_at < 60.days.ago

          domain = UrlHelper.url_with_domain_only(url)

          get = HTTParty.get('https://prospector.clearbit.com/v1/people/search', headers: {'Authorization' => 'Bearer 229daf10e05c493613aa2159649d03b4'}, query: {'domain' => domain})
          new_clearbit_contacts = JSON.load(get.response.body)

          # delete old records (prevents duplicates)
          ClearbitContact.where(website_id: website.id).destroy_all if website

          puts new_clearbit_contacts

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
                clearbit_contact.update(website_id: website.id, clearbit_id: contact_id, given_name: contact_given_name, family_name: contact_family_name, full_name: contact_full_name, title: contact_title, email: contact_email, linkedin: contact_linkedin)
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

end
