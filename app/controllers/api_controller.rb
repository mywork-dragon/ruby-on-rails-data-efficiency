# This is our internal API that talks to the frontend
class ApiController < ApplicationController

  skip_before_filter  :verify_authenticity_token

  before_action :set_current_user, :authenticate_request
  before_action :authenticate_storewide_sdk_request, only: [:search_sdk, :get_sdk, :get_sdk_autocomplete]
  before_action :authenticate_export_request, only: [:export_newest_apps_chart_to_csv, :export_list_to_csv, :export_contacts_to_csv, :export_results_to_csv]
  before_action :authenticate_ios_live_scan, only: [:ios_scan_status, :ios_start_scan] # Authorizing iOS Live Scan routes

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

    company_filters['fortuneRank'] = company_filters['fortuneRank'].to_i if company_filters['fortuneRank']
    app_filters['updatedDaysAgo'] = app_filters['updatedDaysAgo'].to_i if app_filters['updatedDaysAgo']

    filter_args = {
      app_filters: app_filters,
      company_filters: company_filters,
      page_size: (page_size.blank? ? nil : page_size.to_i),
      page_num: (page_num.blank? ? nil : page_num.to_i),
      sort_by: sort_by,
      order_by: order_by
    }

    filter_args.delete_if{ |k, v| v.nil? }

    filter_results = FilterService.filter_ios_apps(filter_args)

    ids = filter_results.map { |result| result.attributes["id"] }
    results = ids.any? ? IosApp.where(id: ids).order("FIELD(id, #{ids.join(',')})") : []
    results_count = filter_results.total_count # the total number of potential results for query (independent of paging)

    render json: {results: results.as_json({user: @current_user}), resultsCount: results_count, pageNum: page_num}
  end

  def filter_android_apps
    app_filters = JSON.parse(params[:app])
    company_filters = JSON.parse(params[:company])
    page_size = params[:pageSize]
    page_num = params[:pageNum]
    sort_by = params[:sortBy]
    order_by = params[:orderBy]

    company_filters.has_key?('fortuneRank') ? company_filters['fortuneRank'] = company_filters['fortuneRank'].to_i : nil
    app_filters.has_key?('updatedDaysAgo') ? app_filters['updatedDaysAgo'] = app_filters['updatedDaysAgo'].to_i : nil

    filter_args = {
      app_filters: app_filters,
      company_filters: company_filters,
      page_size: (page_size.blank? ? nil : page_size.to_i),
      page_num: (page_num.blank? ? nil : page_num.to_i),
      sort_by: sort_by,
      order_by: order_by
    }

    filter_args.delete_if{ |k, v| v.nil? }

    filter_results = FilterService.filter_android_apps(filter_args)

    ids = filter_results.map { |result| result.attributes["id"] }
    results = ids.any? ? AndroidApp.where(id: ids).order("FIELD(id, #{ids.join(',')})") : []
    results_count = filter_results.total_count # the total number of potential results for query (independent of paging)

    render json: {results: results.as_json({user: @current_user}), resultsCount: results_count, pageNum: page_num}
  end

  def newsfeed
    page = [params[:page].to_i, 1].max
    weeks = @current_user.weekly_batches(page)
    newsfeed_json = {
      following: @current_user.following.map{|follow| follow.as_json({user: @current_user})},
      weeks: weeks.map{|week, platforms| {
        week: week.to_s,
        label: view_context.week_formatter(week),
        platforms: platforms.map{|platform, batches| {
          platform: platform,
          batches: batches 
        }}
      }}
    }
    render json: newsfeed_json
  end

  def newsfeed_details
    batch = WeeklyBatch.find(params[:batchId])
    page_num = params[:pageNum].to_i
    per_page = params[:perPage].to_i

    newsfeed = batch.as_json({page: page_num})
    newsfeed[:activities] = batch.sorted_activities(page_num, per_page).map{|activity| {
      id: activity.id,
      happened_at: activity.happened_at,
      other_owner: activity.other_owner(batch.owner),
      impression_count: activity.try(:impression_count)
    }}

    render json: newsfeed.to_json({user: @current_user})
  end

  def newsfeed_follow
    followable_class = params['type'].constantize
    followable = followable_class.find(params['id'])
    
    if @current_user.following?(followable)
      @current_user.unfollow(followable)
    else
      @current_user.follow(followable)
    end
    render json: {:following => @current_user.following?(followable)}
  end

  # Get details of iOS app.
  # Input: appId (the key for the app in our database; not the appIdentifier)
  def get_ios_app
    appId = params['id']
    ios_app = IosApp.find(appId)
    render json: ios_app.to_json({user: @current_user, details: true})
  end

  def get_android_app
    appId = params['id']
    android_app = AndroidApp.find(appId)

    render json: android_app.to_json({user: @current_user, details: true})
  end

  def get_android_developer
    developer = AndroidDeveloper.find(params['id'])
    @developer_json = {}
    if developer.present?
      @developer_json = {
        id: developer.id,
        name: developer.name,
        websites: developer.websites.to_a.map{|w| w.url},
        numApps: developer.android_apps.count,
        apps: developer.sorted_android_apps(params[:sortBy], params[:orderBy], params[:pageNum]).as_json({user: @current_user})
      }
    end
    render json: @developer_json
  end

  def get_ios_developer
    developer = IosDeveloper.find(params['id'])
    @developer_json = {}
    if developer.present?
      @developer_json = {
        id: developer.id,
        name: developer.name,
        websites: developer.get_website_urls,
        numApps: developer.ios_apps.count,
        apps: developer.sorted_ios_apps(params[:sortBy], params[:orderBy], params[:pageNum]).as_json({user: @current_user})
      }
    end
    render json: @developer_json
  end

  def get_company
    companyId = params['id']
    company = Company.includes(websites: {ios_apps: :newest_ios_app_snapshot}).find(companyId)
    @company_json = {}
    if company.present?
      @company_json = company.as_json
      @company_json[:iosApps] = company.get_ios_apps
      @company_json[:androidApps] = company.get_android_apps
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
      'Lifestyle',
      'Magazines & Newspapers',
      'Medical',
      'Music',
      'Navigation',
      'News',
      'Photo & Video',
      'Productivity',
      'Reference',
      'Shopping',
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
    render json: @current_user.lists
  end

  # Get a list, given a user_id and list_id
  def get_list
    list_id = params['listId']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    list = List.find(list_id)

    ios_apps = list.ios_apps
    android_apps = list.android_apps

    results = ios_apps.to_a + android_apps.to_a

    render json: {:resultsCount => results.count, :currentList => list_id, :results => results.as_json({user: @current_user})}
  end

  def export_results_to_csv
    app_filters = JSON.parse(params[:app])
    company_filters = JSON.parse(params[:company])
    platform = JSON.parse(params[:platform])["appPlatform"]

    sort_by = params[:sortBy]
    order_by = params[:orderBy]

    company_filters['fortuneRank'] = company_filters['fortuneRank'].to_i if company_filters['fortuneRank']
    app_filters['updatedDaysAgo'] = app_filters['updatedDaysAgo'].to_i if app_filters['updatedDaysAgo']

    filter_args = {
      app_filters: app_filters,
      company_filters: company_filters,
      sort_by: sort_by,
      order_by: order_by,
      platform: platform
    }

    filter_args.delete_if{ |k, v| v.nil? }
    
    render_csv(filter_args)
  end

  def export_list_to_csv
    list_id = params['listId']
    list = List.find(list_id)

    ios_apps = list.ios_apps
    android_apps = list.android_apps
    apps = []

    header = csv_header

    ios_apps.each do |app|
      apps << app.to_csv_row
    end

    android_apps.each do |app|
      apps << app.to_csv_row
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
    list_name = params['listName']

    render json: @current_user.lists.create(name: list_name)

    # render json: List.find(authenticated_user.id).find(list_name)

  end

  def add_to_list
    list_id = params['listId']
    apps = params['apps']
    app_platform = params['appPlatform']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
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
    list_id = params['listId']
    apps = params['apps']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
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
    list_id = params['listId']
    apps = params['apps']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
      render json: {:error => "not user's list"}
      return
    end

    render json: {:status => 'success'}
  end

  def delete_list
    list_id = params['listId']

    if ListsUser.where(user_id: @current_user.id, list_id: list_id).empty?
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
    render json: { :tos_accepted => @current_user.tos_accepted }
  end

  def user_tos_set

    tos_status = params['tos_accepted']

    if tos_status
      @current_user.tos_accepted = true
      @current_user.save
    end

    render json: { :tos_accepted => @current_user.tos_accepted }
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

  def ios_sdks_exist
    ios_app_id = params['appId']

    render json: IosSdkService.get_tagged_sdk_response(ios_app_id).to_json
  end

  def ios_scan_status
    job_id = params['jobId']

    code = IosLiveScanService.check_status(job_id: job_id)
    render json: {status: code}
  end

  def ios_start_scan
    ios_app_id = params['appId']

    job_id = IosLiveScanService.scan_ios_app(ios_app_id: ios_app_id)

    render json: {job_id: job_id}
  end

  def android_sdks_exist
    id = params['appId']
    json = AndroidSdkService::App.get_sdk_response(id).to_json
    render json: json
  end

  def android_start_scan
    id = params['appId']
    job_id = AndroidSdkService::LiveScan.start_scan(id)
    render json: {job_id: job_id}.to_json
  end

  def android_scan_status
    job_id = params['jobId']
    status_h = AndroidSdkService::LiveScan.check_status(job_id: job_id)
    render json: status_h
  end

  def newest_apps_chart

    page_size = params[:pageSize]
    page_num = params[:pageNum]

    results = IosApp.where(released: Date.new(2015, 7, 24)..Date.new(2015, 7, 30))
    results_count = results.count

    render json: {results: results, resultsCount: results_count, pageNum: page_num}
  end

  def top_apps
    newest_snapshot = IosAppRankingSnapshot.last
    apps = IosApp.joins(:ios_app_rankings).where(ios_app_rankings: {ios_app_ranking_snapshot_id: newest_snapshot.id}).select(:rank, 'ios_apps.*').order('rank ASC')
    render json: {apps: apps, last_updated: newest_snapshot.created_at}
  end

  def sdks
    render json: {sdks: Tag.includes(:ios_sdks).as_json(include: :ios_sdks)}
  end

  def tags
    tags = Tag.where("name LIKE '#{params[:query]}%'")
    render json: tags
  end

  # METHOD USED FOR CREATING CUSTOM CSVs (usually hooked up to export button in UI)
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
            fields: ['name^2', 'seller_url', 'seller'],
            type: 'cross_fields',
            fuzziness: 1
        }
    ).boost_factor(
        3,
        filter: { term: {user_base: 'elite'} }
    ).boost_factor(
        2,
        filter: { term: {user_base: 'strong'} }
    ).boost_factor(
        1,
        filter: { term: {user_base: 'moderate'} }
    )
    result_ids = FilterService.order_helper(result_ids, params[:sortBy], params[:orderBy]) if params[:sortBy] && params[:orderBy]
    result_ids = result_ids.limit(num_per_page).offset((page - 1) * num_per_page)

    total_apps_count = result_ids.total_count # the total number of potential results for query (independent of paging)
    result_ids = result_ids.map { |result| result.attributes["id"] }

    ios_apps = result_ids.map{ |id| IosApp.find_by_id(id) }.compact

    render json: {appData: ios_apps.as_json({user: @current_user}), totalAppsCount: total_apps_count, numPerPage: num_per_page, page: page}
  end

  def search_android_apps
    query = params['query']
    page = !params['page'].nil? ? params['page'].to_i : 1
    num_per_page = !params['numPerPage'].nil? ? params['numPerPage'].to_i : 100

    result_ids = AppsIndex::AndroidApp.query(
      multi_match: {
        query: query,
        operator: 'and',
        fields: ['name^2', 'seller_url', 'seller'],
        type: 'cross_fields',
        fuzziness: 1
      }
    ).boost_factor(
      3,
      filter: { term: {user_base: 'elite'} }
    ).boost_factor(
      2,
      filter: { term: {user_base: 'strong'} }
    ).boost_factor(
      1,
      filter: { term: {user_base: 'moderate'} }
    )
    result_ids = FilterService.order_helper(result_ids, params[:sortBy], params[:orderBy]) if params[:sortBy] && params[:orderBy]
    result_ids = result_ids.limit(num_per_page).offset((page - 1) * num_per_page)
    
    total_apps_count = result_ids.total_count # the total number of potential results for query (independent of paging)
    result_ids = result_ids.map { |result| result.attributes["id"] }

    android_apps = result_ids.map{ |id| AndroidApp.find_by_id(id) }.compact
    
    render json: {appData: android_apps.as_json({user: @current_user}), totalAppsCount: total_apps_count, numPerPage: num_per_page, page: page}
  end

  def search_ios_sdk
    query = params['query'].downcase
    page = !params['page'].nil? ? params['page'].to_i : 1
    num_per_page = !params['numPerPage'].nil? ? params['numPerPage'].to_i : 100

    result_ids = IosSdkIndex::IosSdk.query(
      query_string: {
        query: "#{query}*",
        default_field: 'name',
        analyze_wildcard: true
      }
    ).boost_factor(
      5,
      filter: { term: { name: query } }
    ).limit(num_per_page).offset((page - 1) * num_per_page)

    total_sdks_count = result_ids.total_count # the total number of potential results for query (independent of paging)
    result_ids = result_ids.map { |result| result.attributes["id"] }

    sdks = result_ids.map {|id| IosSdk.find_by_id(id) }.compact

    # sdks = IosSdk.where(id: result_ids)

    render json: {sdkData: sdks, totalSdksCount: total_sdks_count, numPerPage: num_per_page, page: page}
  end

  def search_android_sdk
    query = params['query'].downcase
    page = !params['page'].nil? ? params['page'].to_i : 1
    num_per_page = !params['numPerPage'].nil? ? params['numPerPage'].to_i : 100

    result_ids = AndroidSdkIndex::AndroidSdk.query(
      query_string: {
        query: "#{query}*",
        default_field: 'name',
        analyze_wildcard: true
      }
    ).boost_factor(
      5,
      filter: { term: { name: query } }
    ).limit(num_per_page).offset((page - 1) * num_per_page)

    total_sdks_count = result_ids.total_count # the total number of potential results for query (independent of paging)
    result_ids = result_ids.map { |result| result.attributes["id"] }

    sdks = result_ids.map{ |id| AndroidSdk.find_by_id(id) }.compact

    render json: {sdkData: sdks, totalSdksCount: total_sdks_count, numPerPage: num_per_page, page: page}
  end

  def get_android_sdk
    sdk_id = params['id']
    sdk = AndroidSdk.find(sdk_id)

    @sdk_json = sdk.as_json({user: @current_user})
    @sdk_json[:apps] = sdk.get_current_apps(10, 'user_base').as_json({user: @current_user})
    @sdk_json[:numOfApps] = sdk.get_current_apps.where.not(display_type: 1).size
    render json: @sdk_json
  end

  def get_ios_sdk
    sdk_id = params['id']
    sdk = IosSdk.find(sdk_id)

    @sdk_json = sdk.as_json({user: @current_user})
    @sdk_json[:apps] = sdk.get_current_apps(10, 'user_base').as_json({user: @current_user})
    @sdk_json[:numOfApps] = sdk.get_current_apps.where.not(display_type: 1).size
    render json: @sdk_json
  end

  def update_ios_sdk_tags
    sdk_id = params[:id]
    sdk = IosSdk.find(sdk_id)
    new_tags = []
    if tags = params[:tags]
      tags = JSON.parse(tags)
      puts tags
      tags.each do |tag|
        if tag['id'].present?
          new_tags << Tag.find(tag['id'])
        else
          new_tags << Tag.find_or_create_by(name: tag['text'])
        end
      end
    end
    sdk.tags = new_tags
    render json: sdk
  end

  def get_sdk_autocomplete
    search_str = params['searchstr']
    platform = params['platform']

    sdk_companies = []
    results = []

    if platform == 'android'
      sdk_companies = AndroidSdk.display_sdks.where("name LIKE '#{params['searchstr']}%'").where(flagged: false)
      sdk_companies.each do |sdk|
        results << {id: sdk.id, name: sdk.name, favicon: sdk.get_favicon}
      end
    elsif platform == 'ios'
      sdk_companies = IosSdk.display_sdks.where("name LIKE '#{params['searchstr']}%'").where(flagged: false)
      sdk_companies.each do |sdk|
        results << {id: sdk.id, name: sdk.name, favicon: sdk.favicon}
      end
    end

    render json: {searchParam: search_str, results: results}
  end

  def get_sdk_scanned_count
    scanned_android_sdk_num = ApkSnapshot.where(scan_status: 1).select(:android_app_id).distinct.count
    scanned_ios_sdk_num = IpaSnapshot.where(scan_status: 1).select(:ios_app_id).distinct.count

    render json: {scannedAndroidSdkNum: scanned_android_sdk_num, scannedIosSdkNum: scanned_ios_sdk_num}
  end

  private

  def render_csv(filter_args)
    set_file_headers
    set_streaming_headers

    response.status = 200

    self.response_body = csv_lines(filter_args)
  end

  def set_file_headers
    file_name = "mightsignal_apps.csv"
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
  end


  def set_streaming_headers
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end

  def csv_header
    headers = ['MightySignal App ID', 'App Store/Google Play ID', 'App Name', 'App Type', 'Mobile Priority', 'User Base', 'Last Updated', 'Ad Spend', 'Categories', 'MightySignal Publisher ID', 'Publisher Name', 'App Store/Google Play Publisher ID', 'Fortune Rank', 'Publisher Website(s)', 'MightySignal App Page', 'MightySignal Publisher Page', 'Ratings', 'Downloads']
  end

  def csv_lines(filter_args)
    Enumerator.new do |y|
      y << csv_header.to_csv

      filter_args[:page_size] = 10000
      filter_args[:page_num] = 1
      filter_results = nil
      platform = filter_args.delete(:platform)

      #while !filter_results || filter_results.count > 0
        if platform == 'ios'
          filter_results = FilterService.filter_ios_apps(filter_args)
          filter_results = FilterService.order_helper(filter_results, filter_args[:sort_by], filter_args[:order_by]) if filter_args[:sort_by] && filter_args[:order_by]
          ids = filter_results.map { |result| result.attributes["id"] }
          results = IosApp.where(id: ids).includes(:ios_developer, :newest_ios_app_snapshot).order("FIELD(id, #{ids.join(',')})") if ids.any?
        else
          filter_results = FilterService.filter_android_apps(filter_args)
          filter_results = FilterService.order_helper(filter_results, filter_args[:sort_by], filter_args[:order_by]) if filter_args[:sort_by] && filter_args[:order_by]
          ids = filter_results.map { |result| result.attributes["id"] }
          results = AndroidApp.where(id: ids).includes(:android_developer, :newest_android_app_snapshot).order("FIELD(id, #{ids.join(',')})") if ids.any?
        end

        if ids.any?
          results.each do |app|
            y << app.to_csv_row.to_csv
          end
          filter_args[:page_num] += 1
        end
      #end
    end
  end
end