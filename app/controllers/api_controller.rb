# This is our internal API that talks to the frontend
class ApiController < ApplicationController
  include ApiHelper

  skip_before_filter  :verify_authenticity_token

  before_action :set_current_user, :authenticate_request
  before_action :authenticate_storewide_sdk_request, only: [:search_sdk, :get_sdk, :get_sdk_autocomplete]
  before_action :authenticate_export_request, only: [:export_newest_apps_chart_to_csv, :export_list_to_csv, :export_contacts_to_csv, :export_results_to_csv]
  before_action :authenticate_ios_live_scan, only: [:ios_scan_status, :ios_start_scan] # Authorizing iOS Live Scan routes
  before_action :authenticate_ad_intelligence, only: :ad_intelligence

  def initialize
    @contact_service = ContactDiscoveryService.new
  end

  def check_app_status
    if ServiceStatus.is_active?(:general_maintenance)
      message = ServiceStatus.find_by_service(ServiceStatus.get_info(:general_maintenance)).outage_message
      render json: { error: message }
    else
      render json: { status: "ok" }
    end
  end

  def filter_ios_apps

    li 'filter_ios_apps'

    app_filters = JSON.parse(params[:app])
    company_filters = JSON.parse(params[:company])

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

    userbase_filter = app_filters['userBases'] || []

    app_ids = filter_results.map { |result| result.attributes["id"].to_i }
    apps_json = app_ids.any? ? IosApp.where(id: app_ids).order("FIELD(id, #{app_ids.join(',')})").as_json({user: @current_user, user_bases: userbase_filter}) : []

    results_count = filter_results.total_count # the total number of potential results for query (independent of paging)

    render json: {results: apps_json, resultsCount: results_count, pageNum: page_num}
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

  def new_advertiser_counts
    now = DateTime.now
    sunday = now - now.wday
    week_filter = {"range" => {"first_seen_ads" => {"format" => "date_time", "gte" => sunday}}}
    render json: {
      total: AppsIndex.filter(week_filter).total_count,
      ios: AppsIndex::IosApp.filter(week_filter).total_count,
      android: AppsIndex::AndroidApp.filter(week_filter).total_count
    }
  end

  def new_advertisers_csv
    now = DateTime.now
    sunday = now - now.wday
    week_filter = {"range" => {"first_seen_ads" => {"format" => "date_time", "gte" => sunday}}}
    apps_index = case params[:platform]
      when 'combined'
        AppsIndex
      when 'ios'
        AppsIndex::IosApp
      when 'android'
        AppsIndex::AndroidApp
    end
    new_advertisers = apps_index.filter(week_filter).order('first_seen_ads' => {'order' => 'desc'}).limit(200)
    render_csv(apps: new_advertisers)
  end

  def combined_ad_intelligence
    filter_args = {
      sort_by: params[:sortBy] || 'first_seen_ads',
      order_by: params[:orderBy] || 'desc',
      page_num: params[:pageNum] ? params[:pageNum].to_i : 1,
      page_size: request.format.json? ? 20 : 10000
    }

    filter_results = FilterService.filter_ad_spend_apps(filter_args)

    respond_to do |format|
      if request.format.json?
        results = filter_results.map do |result|
          app_id = result.attributes["id"]
          result.class.name == 'AppsIndex::IosApp' ? IosApp.find(app_id) : AndroidApp.find(app_id)
        end
        format.json { render json:
          {
            results: results.as_json(ads: true),
            resultsCount: filter_results.total_count,
            pageNum: filter_args[:page_num],
            pageSize: filter_args[:page_size]
          }
        }
      end
      format.csv { render_csv(apps: filter_results) }
    end
  end

  def ios_ad_intelligence
    filter_args = {
      sort_by: params[:sortBy] || 'first_seen_ads',
      order_by: params[:orderBy] || 'desc',
      page_num: params[:pageNum] ? params[:pageNum].to_i : 1,
      page_size: request.format.json? ? 20 : 10000
    }

    filter_results = FilterService.filter_ios_ad_spend_apps(filter_args)

    respond_to do |format|
      if request.format.json?
        results = filter_results.map { |result| IosApp.find(result.attributes["id"]) }
        format.json { render json:
          {
            results: results.as_json(ads: true),
            resultsCount: filter_results.total_count,
            pageNum: filter_args[:page_num],
            pageSize: filter_args[:page_size]
          }
        }
      end
      format.csv { render_csv(apps: filter_results) }
    end
  end

  def android_ad_intelligence
    page_size = params[:pageSize] ? params[:pageSize].to_i : 20
    page_num = params[:pageNum] ? params[:pageNum].to_i : 1
    params[:sortBy] ||= 'first_seen_ads'
    sort_by = if params[:sortBy] == 'first_seen_ads'
      'min(date_seen)'
    elsif params[:sortBy] == 'last_seen_ads'
      'max(date_seen)'
    else params[:sortBy] == 'user_base'
      'user_base IS NULL, user_base'
    end
    order_by = ['desc', 'asc'].include?(params[:orderBy]) ? params[:orderBy] : 'desc'

    results = AndroidApp.joins(:android_ads).
                                       order("#{sort_by} #{order_by}").group('android_apps.id')
    results = results.page(page_num).per(page_size) if request.format.json?
    respond_to do |format|
      format.json { render json:
        {
          results: results.as_json(ads: true),
          resultsCount: results.total_count,
          pageNum: page_num,
          pageSize: page_size
        }
      }
      format.csv { render_csv(apps: results) }
    end
  end

  def newsfeed
    page = [params[:page].to_i, 1].max
    country_codes = params[:country_codes]
    weeks = @current_user.weekly_batches(page, country_codes)
    newsfeed_json = {
      following: @current_user.following.as_json({user: @current_user}),
      weeks: weeks.map{|week, platforms| {
        week: week.to_s,
        label: view_context.week_formatter(week),
        platforms: platforms.map{|platform, batches| {
          platform: platform,
          batches: batches.as_json(country_codes: country_codes)
        }}
      }}
    }
    render json: newsfeed_json
  end

  def newsfeed_details
    batch = WeeklyBatch.find(params[:batchId])
    country_codes = params[:country_codes]
    page_num = params[:pageNum].to_i
    per_page = params[:perPage].to_i

    newsfeed = batch.as_json({page: page_num})
    newsfeed[:activities] = batch.sorted_activities(page_num: page_num, per_page: per_page, country_codes: country_codes).map{|activity| {
      id: activity.id,
      happened_at: activity.happened_at,
      other_owner: activity.other_owner(batch.owner),
      impression_count: activity.try(:impression_count)
    }}

    render json: newsfeed.to_json({user: @current_user})
  end

  def newsfeed_export
    batch = WeeklyBatch.find(params[:batchId])
    country_codes = params[:country_codes]
    apps = batch.sorted_activities(country_codes: country_codes).map{|activity| activity.other_owner(batch.owner)}

    header = csv_header

    apps_csv = CSV.generate do |csv|
      csv << header
      apps.each do |app|
        csv << app.to_csv_row
      end
    end

    send_data apps_csv
  end

  def newsfeed_follow
    followable_class = params['type'].constantize
    followable = followable_class.find(params['id'])

    if @current_user.following?(followable)
      @current_user.unfollow(followable)
    else
      @current_user.follow(followable)
    end
    render json: {
                  is_following: @current_user.following?(followable),
                  following: @current_user.following.as_json({user: @current_user})
                }
  end

  def newsfeed_add_country
    country_code = params[:country_code]
    @current_user.users_countries.find_or_create_by(country_code: country_code)
    render json: {success: true}
  end

  def newsfeed_remove_country
    country_code = params[:country_code]
    @current_user.users_countries.where(country_code: country_code).delete_all
    render json: {success: true}
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
        headquarters: developer.headquarters,
        fortuneRank: developer.fortune_1000_rank,
        numApps: developer.num_apps,
        isMajorPublisher: developer.is_major_publisher?,
        linkedin: developer.linkedin_handle,
        companySize: developer.company_size,
        crunchbase: developer.crunchbase_handle,
        logo: developer.logo_url
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
        headquarters: developer.headquarters,
        fortuneRank: developer.fortune_1000_rank,
        numApps: developer.num_apps,
        isMajorPublisher: developer.is_major_publisher?,
        linkedin: developer.linkedin_handle,
        companySize: developer.company_size,
        crunchbase: developer.crunchbase_handle,
        logo: developer.logo_url
      }
    end
    render json: @developer_json
  end

  def get_developer_apps
    developer = params['platform'] == 'ios' ? IosDeveloper.find(params['id']) : AndroidDeveloper.find(params['id'])
    apps = developer.sorted_apps(params[:sortBy], params[:orderBy], params[:pageNum])
    render json: { apps: apps.as_json({user: @current_user}) }
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

  def get_android_category_objects
    render json: AndroidAppCategory.all.map {|x| x.as_json}
  end

  def get_android_categories
    # AndroidAppCategory.select(:name).joins(:android_app_categories_snapshots).group('android_app_categories.id').where('android_app_categories.name <> "Category:"').order('name asc').to_a.map{|cat| cat.name}
    categories = [
      'Art & Design',
      'Auto & Vehicles',
      'Beauty',
      'Books & Reference',
      'Business',
      'Comics',
      'Communication',
      'Dating',
      'Education',
      'Entertainment',
      'Events',
      'Family',
      'Finance',
      'Food & Drink',
      'Games',
      'Health & Fitness',
      'House and Home',
      'Libraries & Demo',
      'Lifestyle',
      'Video Players & Editors',
      'Medical',
      'Music & Audio',
      'News & Magazines',
      'Parenting',
      'Personalization',
      'Photography',
      'Productivity',
      'Shopping',
      'Social',
      'Sports',
      'Tools',
      'Maps & Navigation',
      'Travel & Local',
      'Weather'
    ]
    render json: categories
  end

  def get_ios_sdk_categories
    categories = {}
    Tag.select(:id, :name).order(:name).joins(:ios_sdks).group(:tag_id).having('count(tag_id) > ?', 0).each do |tag|
      categories[tag.name] = {
        id: tag.id,
        name: tag.name,
        sdks: tag.ios_sdks.as_json.sort_by { |sdk| sdk[:name] }
      }
    end

    render json: categories
  end

  def get_android_sdk_categories
    categories = {}
    Tag.select(:id, :name).order(:name).joins(:android_sdks).group(:tag_id).having('count(tag_id) > ?', 0).map do |tag|
      categories[tag.name] = {
        id: tag.id,
        name: tag.name,
        sdks: tag.android_sdks.as_json.sort_by { |sdk| sdk[:name] }
      }
    end

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

    render_csv(filter_args: filter_args)
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
    platform = params['platform']
    publisher_id = params['publisherId']

    developer = if platform == 'ios'
      IosDeveloper.find(publisher_id)
    else
      AndroidDeveloper.find(publisher_id)
    end

    filter = params['filter']

    contacts = @contact_service.get_contacts_for_developer(developer, filter)

    companyName = params['companyName']
    header = ['MightySignal ID', 'Company Name', 'Title', 'Full Name', 'First Name', 'Last Name', 'Email', 'LinkedIn']

    list_csv = CSV.generate do |csv|
      csv << header
      contacts.each do |contact|
        contact = contact.with_indifferent_access
        contacts_hash = [
          contact['clearbitId'],
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

    apps.each { |app| ListablesList.find_by(listable_id: app['id'], list_id: list_id, listable_type: app['type']).destroy }

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

  def get_contact_email
    contact_id = params['contactId']
    begin
      email = @contact_service.get_contact_email(contact_id)
    rescue
      render json: {error: "Emails are temporarily unavailable. Please try again later", status: 500}
      return
    end
    render json: {email: email}
  end

  def get_company_contacts
    platform = params['platform']
    publisher_id = params['publisherId']

    filter = params['filter']
    page = params['page'] || 1
    offset = params['perPage'] || 10

    developer = if platform == 'ios'
      IosDeveloper.find(publisher_id)
    else
      AndroidDeveloper.find(publisher_id)
    end
    contacts = @contact_service.get_contacts_for_developer(developer, filter)
    render json: {:contacts => contacts[((page-1)*offset)..((page*offset)-1)], contactsCount: contacts.count}
  end

  def ios_sdks_exist
    if params['appId']
      render json: IosSdkService.get_tagged_sdk_response(params['appId'], force_live_scan_enabled: logged_into_admin_account?).to_json
    elsif params['publisherId']
      render json: IosDeveloper.find(params['publisherId']).tagged_sdk_summary
    end
  end

  def ios_scan_status
    job_id = params['jobId']

    code = IosLiveScanService.check_status(job_id: job_id)
    render json: {status: code}
  end

  def ios_start_scan
    ios_app_id = params['appId']

    job_id = IosLiveScanService.scan_ios_app(
      ios_app_id: ios_app_id,
      international_enabled: ServiceStatus.is_active?(:ios_international_live_scan)
    )

    render json: {job_id: job_id}
  end

  def android_sdks_exist
    if params['appId']
      render json: AndroidSdkService::App.get_tagged_sdk_response(params['appId'], force_live_scan_enabled: logged_into_admin_account?).to_json
    elsif params['publisherId']
      render json: AndroidDeveloper.find(params['publisherId']).tagged_sdk_summary
    end
  end

  def android_start_scan
    id = params['appId']
    job_id = AndroidLiveScanService.start_scan(id)
    render json: {job_id: job_id}.to_json
  end

  def android_scan_status
    job_id = params['jobId']
    status_h = AndroidLiveScanService.check_status(job_id: job_id)
    render json: {status: status_h}
  end

  def newest_apps_chart

    page_size = params[:pageSize]
    page_num = params[:pageNum]

    results = IosApp.where(released: Date.new(2015, 7, 24)..Date.new(2015, 7, 30))
    results_count = results.count

    render json: {results: results, resultsCount: results_count, pageNum: page_num}
  end

  def top_ios_apps
    newest_snapshot = IosAppRankingSnapshot.last_valid_snapshot
    last_updated = newest_snapshot.try(:created_at) || Time.now
    apps = if newest_snapshot
              IosApp.joins(:ios_app_rankings).where(ios_app_rankings: {ios_app_ranking_snapshot_id: newest_snapshot.id}).select(:rank, 'ios_apps.*').order('rank ASC')
            else
              []
            end
    render json: {apps: apps, last_updated: last_updated}
  end

  def top_android_apps
    newest_snapshot = AndroidAppRankingSnapshot.last_valid_snapshot
    last_updated = newest_snapshot.try(:created_at) || Time.now
    apps = if newest_snapshot
              AndroidApp.joins(:android_app_rankings).where(android_app_rankings: {android_app_ranking_snapshot_id: newest_snapshot.id}).
                        select(:rank, 'android_apps.*').order('rank ASC').limit(200)
            else
              []
            end
    render json: {apps: apps, last_updated: last_updated}
  end

  def ios_engagement
    filter_args = {
      app_filters: {},
      company_filters: {},
      page_size: 100,
      page_num: 1,
      order_by: params[:orderBy],
      sort_by: params[:sortBy],
    }

    filter_results = FilterService.filter_ios_apps(filter_args)
    filter_results = FilterService.order_helper(filter_results, filter_args[:sort_by], filter_args[:order_by])

    ids = filter_results.map { |result| result.attributes["id"] }
    apps = IosApp.where(id: ids).order("FIELD(id, #{ids.join(',')})") if ids.any?

    respond_to do |format|
      format.json {
        render json: {apps: apps.as_json(engagement: true)}
      }
      format.csv {
        render_csv(apps: apps)
      }
    end
  end

  def ios_sdks
    render json: {sdks: Tag.includes(:ios_sdks).as_json(include: :ios_sdks)}
  end

  def android_sdks
    render json: {sdks: Tag.includes(:android_sdks).as_json(include: :android_sdks)}
  end

  def tags
    tags = Tag.where("name LIKE ?", "#{params[:query]}%")
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
            fields: ['name.title^2', 'seller_url', 'seller'],
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

    ios_apps = result_ids.any? ? IosApp.where(id: result_ids).order("FIELD(id, #{result_ids.join(',')})").is_ios : []

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
        fields: ['name.title^2', 'seller_url', 'seller'],
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

    render json: {sdkData: sdks.as_json(user: @current_user), totalSdksCount: total_sdks_count, numPerPage: num_per_page, page: page}
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

    render json: {sdkData: sdks.as_json(user: @current_user), totalSdksCount: total_sdks_count, numPerPage: num_per_page, page: page}
  end

  def get_android_sdk
    sdk_id = params['id']
    sdk = AndroidSdk.find(sdk_id)

    @sdk_json = sdk.as_json({user: @current_user})

    sdk_apps = sdk.get_current_apps(limit: 10, sort: 'ratings_all', order: 'desc')
    @sdk_json[:apps] = sdk_apps[:apps].as_json({user: @current_user})
    @sdk_json[:numOfApps] = sdk_apps[:total_count]
    render json: @sdk_json
  end

  def get_ios_sdk
    sdk_id = params['id']
    sdk = IosSdk.find(sdk_id)
    @sdk_json = sdk.as_json({user: @current_user})

    sdk_apps = sdk.get_current_apps(limit: 10, sort: 'ratings_all', order: 'desc')
    @sdk_json[:apps] = sdk_apps[:apps].as_json({user: @current_user})
    @sdk_json[:numOfApps] = sdk_apps[:total_count]

    render json: @sdk_json
  end

  def update_sdk_tags
    sdk_id = params[:id]
    model = params[:platform] == 'ios' ? IosSdk : AndroidSdk
    sdk = model.find(sdk_id)
    new_tags = []
    if tags = params[:tags]
      tags = JSON.parse(tags)
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
    query = params['query']
    platform = params['platform']

    sdk_companies = []
    results = []

    if platform == 'android'
      sdk_companies = AndroidSdk.display_sdks.where("name LIKE ?", "#{query}%").where(flagged: false)
      sdk_companies.each do |sdk|
        results << {id: sdk.id, name: sdk.name, favicon: sdk.get_favicon, platform: 'Android'}
      end
    elsif platform == 'ios'
      sdk_companies = IosSdk.display_sdks.where("name LIKE ?", "#{query}%").where(flagged: false)
      sdk_companies.each do |sdk|
        results << {id: sdk.id, name: sdk.name, favicon: sdk.favicon, platform: 'iOS'}
      end
    end

    render json: {searchParam: query, results: results}
  end

  def get_sdk_scanned_count
    scanned_android_sdk_num = ApkSnapshot.where(scan_status: 1).select(:android_app_id).distinct.count
    scanned_ios_sdk_num = IpaSnapshot.where(scan_status: 1).select(:ios_app_id).distinct.count

    render json: {scannedAndroidSdkNum: scanned_android_sdk_num, scannedIosSdkNum: scanned_ios_sdk_num}
  end

  def get_location_autocomplete
    query = params['query']

    status = params['status']
    if status.to_i == 0
      countries = ISO3166::Country.all.select{|country| country.name.downcase.include?(query.downcase)}.map{|country| {id: country.alpha2, name: country.name, states: country.states.map{|k,v| {state_code: k, state: v["name"]}}, icon: "/lib/images/flags/#{country.alpha2.downcase}.png"}}
    else
      countries = AppStore.enabled.where("name LIKE ?", "#{query}%").map{|store| {id: store.country_code, name: store.name, icon: "/lib/images/flags/#{store.country_code.downcase}.png"}}
    end
    render json: {searchParam: query, results: countries}
  end

  def blog_feed
    require 'rss'
    require 'open-uri'
    rss = RSS::Parser.parse(open('https://blog.mightysignal.com/feed').read, false).items
    result = rss.select { |result| result.categories.none? { |category| category.content == "engineering" } }.first
    pub_date = result.pubDate.to_date;
    if Date.today - pub_date > 4
      render json: { :message => "No new posts" }
      return
    end
    render json: { title: result.title, author: result.dc_creator, link: result.link, pubDate: pub_date }
  end

  private

  def render_csv(filter_args: nil, apps: nil)
    set_file_headers
    set_streaming_headers

    response.status = 200

    self.response_body = csv_lines(filter_args: filter_args, apps: apps)
  end

  def set_file_headers
    file_name = "mightysignal_apps.csv"
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
  end


  def set_streaming_headers
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end

  def csv_header
    headers = ['MightySignal App ID', 'App Store/Google Play ID', 'App Name', 'App Type', 'Mobile Priority', 'Release Date', 'Last Updated', 'Ad Spend', 'First Seen Ads', 'Last Seen Ads',
               'In App Purchases', 'Categories', 'MightySignal Publisher ID', 'Publisher Name', 'App Store/Google Play Publisher ID',
               'Fortune Rank', 'Publisher Website(s)', 'MightySignal App Page', 'MightySignal Publisher Page', 'Ratings', 'Downloads', 'Street Numbers', 'Street Names',
               'Cities', 'States', 'Countries', 'Postal Codes']
    AppStore.enabled.order("display_priority IS NULL, display_priority ASC").each do |store|
      headers << "User Base - #{store.country_code}"
    end
    headers
  end

  def csv_lines(filter_args: nil, apps: nil)
    Enumerator.new do |y|
      y << csv_header.to_csv

      if filter_args
        filter_args[:page_size] = 1000
        filter_args[:page_num] = 1
        filter_args[:order_by] ||= 'asc'
        filter_args[:sort_by] ||= 'name'
        platform = filter_args.delete(:platform)

        filter_results = nil
        results = []

        while filter_results.nil? || (filter_args[:page_num] <= 20 && filter_results.count > 0)
          if platform == 'ios'
            filter_results = FilterService.filter_ios_apps(filter_args)
            results = FilterService.order_helper(filter_results, filter_args[:sort_by], filter_args[:order_by])
          else
            filter_results = FilterService.filter_android_apps(filter_args)
            results = FilterService.order_helper(filter_results, filter_args[:sort_by], filter_args[:order_by])
          end

          if results.any?
            add_apps_to_enum(results: results, enum: y)
            filter_args[:page_num] += 1
          end
        end
      else
        add_apps_to_enum(results: apps, enum: y)
      end
    end
  end

  def add_apps_to_enum(results:, enum:)
    results.each do |app|
      app_csv = if ['IosApp', 'AndroidApp'].include?(app.class.name)
        app.to_csv_row
      else
        app.class.name == 'AppsIndex::IosApp' ? es_ios_app_to_csv(app) : es_android_app_to_csv(app)
      end
      enum << app_csv.to_csv
    end
  end
end
