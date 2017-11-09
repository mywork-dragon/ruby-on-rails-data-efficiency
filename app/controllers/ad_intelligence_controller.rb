class AdIntelligenceController < ApplicationController
  include ApiHelper
  skip_before_filter  :verify_authenticity_token

  before_action :set_current_user, :authenticate_request
  before_action :authenticate_ad_intelligence

  def available_sources
    expires_in 1.minutes
    render json: @current_user.account.available_ad_sources
  end

  def ad_intelligence_query
    expires_in 15.minutes
    page_size = [params[:pageSize] ? params[:pageSize].to_i : 20, AdDataAccessor::MAX_PAGE_SIZE].min
    page_num = params[:pageNum] ? params[:pageNum].to_i : 1
    first_seen_ads_date = params[:firstSeenAds] ? DateTime.parse(params[:firstSeenAds]) : nil
    last_seen_ads_date = params[:lastSeenAds] ? DateTime.parse(params[:lastSeenAds]) : nil
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
          pageNum: page_num,
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
