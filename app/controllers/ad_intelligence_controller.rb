class AdIntelligenceController < ApplicationController
  include ApiHelper
  skip_before_filter  :verify_authenticity_token

  before_action :set_current_user, :authenticate_request
  before_action :authenticate_ad_intelligence
  before_action :authenticate_admin_account, only: [:get_account_settings, :update_account_settings]

  def _get_platform
    if ['ios', 'android'].include? params[:platform]
      return params[:platform]
    else
      raise ActionController::RoutingError, 'Not Found'
    end
  end

  def _get_publisher_and_apps
    publisher_id = params[:publisher_id]
    platform = _get_platform
    if platform == 'ios'
      publisher = IosDeveloper.find(publisher_id)
      apps = publisher.ios_apps
    elsif platform == 'android'
      publisher = AndroidDeveloper.find(publisher_id)
      apps = publisher.android_apps
      else
        raise ActionController::RoutingError, 'Not Found'
      end
    return publisher, apps
  end

  def _get_apps
    app_ids = JSON.parse(params[:appIds])
    if params[:platform] == 'ios'
      app_model = IosApp
    elsif params[:platform] == 'android'
      app_model = AndroidApp
    else
      raise ActionController::RoutingError, 'Not Found'
    end
    app_ids.map do |id|
      app_model.find(id)
    end
  end

  def ad_intel_publisher_creatives
    #expires_in 15.minutes
    page_size = [params[:pageSize] ? params[:pageSize].to_i : 10, AdDataAccessor::MAX_PAGE_SIZE].min
    page_num = params[:pageNum] ? params[:pageNum].to_i : 1
    user_page_num = page_num
    page_num = page_num - 1
    first_seen_date = params[:firstSeenCreative] ? DateTime.parse(params[:firstSeenCreative]) : nil
    last_seen_date = params[:lastSeenCreative] ? DateTime.parse(params[:lastSeenCreative]) : nil
    params[:sortBy] ||= 'first_seen_creative_date'
    formats = params[:formats] ? JSON.parse(params[:formats]) : nil
    source_ids = params[:sourceIds] ? JSON.parse(params[:sourceIds]) : nil
    order_by = ['desc', 'asc'].include?(params[:orderBy]) ? params[:orderBy] : 'desc'
    platform = _get_platform

    publisher, apps = _get_publisher_and_apps

    results, results_count = AdDataAccessor.new.fetch_creatives(
      @current_user.account,
      apps,
      platform,
      source_ids: source_ids,
      first_seen_creative_date: first_seen_date,
      last_seen_creative_date: last_seen_date,
      sort_by: params[:sortBy],
      order_by: order_by,
      page_size: page_size,
      page_number: page_num,
      group_by_app_id: false,
      formats: formats)

    respond_to do |format|
      format.json {
        render json: {
          results: results,
          resultsCount: results_count,
          pageNum: user_page_num,
          pageSize: page_size
        }
      }
    end


  end

  def ad_intel_app_summaries
    expires_in 15.minutes
    source_ids = params[:sourceIds] ? JSON.parse(params[:sourceIds]) : nil
    platform = _get_platform

    if !params[:publisher_id].nil?
      # Grab apps from publisher
      publisher, apps = _get_publisher_and_apps
    else
      # Get apps from params
      apps = _get_apps
    end

    results = AdDataAccessor.new.fetch_app_summaries(
      @current_user.account,
      apps,
      platform,
      source_ids: source_ids
      )

    respond_to do |format|
      format.json {
        render json: results
      }
    end
  end

  def creatives
    expires_in 15.minutes
    page_size = [params[:pageSize] ? params[:pageSize].to_i : 10, AdDataAccessor::MAX_PAGE_SIZE].min
    page_num = params[:pageNum] ? params[:pageNum].to_i : 1
    user_page_num = page_num
    page_num = page_num - 1
    first_seen_date = params[:firstSeenCreative] ? DateTime.parse(params[:firstSeenCreative]) : nil
    last_seen_date = params[:lastSeenCreative] ? DateTime.parse(params[:lastSeenCreative]) : nil
    source_ids = params[:sourceIds] ? JSON.parse(params[:sourceIds]) : nil
    params[:sortBy] ||= 'first_seen_creative_date'
    formats = params[:formats] ? JSON.parse(params[:formats]) : nil
    order_by = ['desc', 'asc'].include?(params[:orderBy]) ? params[:orderBy] : 'desc'
    platform = _get_platform

    apps = _get_apps

    results, results_count = AdDataAccessor.new.fetch_creatives(
      @current_user.account,
      apps,
      platform,
      source_ids: source_ids,
      first_seen_creative_date: first_seen_date,
      last_seen_creative_date: last_seen_date,
      sort_by: params[:sortBy],
      order_by: order_by,
      page_size: page_size,
      page_number: page_num,
      formats: formats)

    respond_to do |format|
      format.json {
        render json: {
          results: results,
          resultsCount: results_count,
          pageNum: user_page_num,
          pageSize: page_size
        }
      }

      format.csv {
        set_file_headers(file_name:"mightysignal_creatives.csv")
        set_streaming_headers
        self.response_body = CSV.generate(headers:results.values[0]['creatives'][0].keys, write_headers: true) do |csv|
          results.values.map do |app|
            app['creatives'].map do |creative|
              csv << creative
            end
          end
        end
      }
    end
  end

  def available_sources
    expires_in 1.minutes
    render json: @current_user.account.available_ad_sources
  end

  def get_account_settings
    account = Account.find(params[:account_id])
    render json: account.account_ad_data_settings
  end

  def update_account_settings
    account = Account.find(params[:account_id])
    settings = JSON.parse(params[:settings])
    active_networks = []

    account.clear_ad_permissions!

    settings['ad_network_tiers'].each do |key, tier|
      if tier['can_access']
        account.enable_ad_network_tier!(key)
        active_networks = tier['networks']
      else
        account.disable_ad_network_tier!(key)
      end
    end

    settings['ad_networks'].each do |id, network|
      included_in_tier = active_networks.include?(id)
      if network['hidden']
        account.hide_ad_network!(id)
      elsif included_in_tier && !network['can_access']
        account.disable_ad_network!(id)
      elsif !included_in_tier && network['can_access']
        account.enable_ad_network!(id)
      end
    end

    render json: account.account_ad_data_settings
  end

  def ad_intelligence_query
    expires_in 15.minutes
    page_size = [params[:pageSize] ? params[:pageSize].to_i : 20, AdDataAccessor::MAX_PAGE_SIZE].min
    page_num = params[:pageNum] ? params[:pageNum].to_i : 1
    first_seen_ads_date = params[:firstSeenAds] ? DateTime.parse(params[:firstSeenAds]) : nil
    last_seen_ads_date = params[:lastSeenAds] ? DateTime.parse(params[:lastSeenAds]) : nil
    user_page_num = page_num
    page_num = page_num - 1
    params[:sortBy] ||= 'first_seen_ads_date'
    order_by = ['desc', 'asc'].include?(params[:orderBy]) ? params[:orderBy] : 'desc'

    source_ids = params[:sourceIds] ? JSON.parse(params[:sourceIds]) : nil

    respond_to do |format|

      format.json {
        results, results_count = AdDataAccessor.new.query(
          @current_user.account,
          platforms: JSON.parse(params[:platforms]),
          source_ids: source_ids,
          sort_by: params[:sortBy],
          first_seen_ads_date: first_seen_ads_date,
          last_seen_ads_date: last_seen_ads_date,
          order_by: order_by,
          page_size: page_size,
          page_number: page_num)

        render json: {
          results: results,
          resultsCount: results_count,
          pageNum: user_page_num,
          pageSize: page_size
        }

      }
      format.csv {
        results, results_count = AdDataAccessor.new.raw_query(
          @current_user.account,
          platforms: JSON.parse(params[:platforms]),
          source_ids: source_ids,
          sort_by: params[:sortBy],
          first_seen_ads_date: first_seen_ads_date,
          last_seen_ads_date: last_seen_ads_date,
          order_by: order_by,
          page_size: page_size,
          page_number: page_num,
          extra_fields: [['apps.id', 'id']]
          )
        ios_apps = results.select{|x| x['platform'] == 'ios' }
        android_apps = results.select{|x| x['platform'] == 'android' }

        # Used to join to streamed csv rows
        app_index = {}
        results.map do |app|
          app_type = app['platform'] == 'ios' ? 'IosApp' : 'AndroidApp'
          app_index["#{app_type}:#{app['id']}"] = app
        end

        ios_apps_e = AppsIndex::IosApp.limit(AdDataAccessor::MAX_PAGE_SIZE).filter({"terms" => {"id" => ios_apps.map{|x| x['id']}}}).to_a
        android_apps_e = AppsIndex::AndroidApp.limit(AdDataAccessor::MAX_PAGE_SIZE).filter({"terms" => {"id" => android_apps.map{|x| x['id']}}}).to_a

        self.response_body  = render_csv(apps: android_apps_e + ios_apps_e, additional_fields: ['Ad Formats', 'Ad Networks', 'Last Seen Ads', 'First Seen Ads']) do |header, csv_row|
          # This block adds to the standard CSV rows we generate.
          app_index_key = "#{csv_row[header.index('App Type')]}:#{csv_row[header.index('MightySignal App ID')]}"
          app_hash  = app_index[app_index_key]

          csv_row.append(app_hash['ad_formats'].map {|x| x['name']}.join('|'))
          csv_row.append(app_hash['ad_sources'].map {|x| x['name']}.join('|'))
          csv_row.append(app_hash['last_seen_ads_date'])
          csv_row.append(app_hash['first_seen_ads_date'])

          csv_row
        end
      }
    end
  end
end
