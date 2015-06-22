require 'mixpanel-ruby'

# The controller for the API that we give to our customers
# Not to be confused with ApiController, which is our internal API to communicated with the frontend
# @author Jason Lew
class CustomerApiController < ApplicationController
  
  API_KEY_NAME = 'MightySignal-API-Key'
  
  skip_before_filter :verify_authenticity_token
  
  if Rails.env.production?
    before_action :authenticate_request, except: [:ping]
    before_action :mixpanel_tracker, except: [:ping]
  end

  def authenticate_request
    key = request.headers[API_KEY_NAME]
    render json: {error: {code: 401, message: 'Unauthorized – Your API key is wrong.'}}, status: 401 if key.blank? || !ApiKey.find_by_key(key)
  end
  
  def ping
    render json: {success: true, server: 'api'}
  end

  def ios_apps
    begin
      app_identifier = params['appStoreId'].to_i
      properties = {'app_identifier' => app_identifier.to_s}

      ios_app = IosApp.find_by_app_identifier(app_identifier)

      if ios_app.blank?
        app_json = {}
      else
        company = ios_app.get_company #could be nil, if no websites, or websites don't have company
        newest_app_snapshot = ios_app.newest_ios_app_snapshot
        newest_download_snapshot = ios_app.get_newest_download_snapshot
        app_json = {
          mightySignalId: ios_app.id,
          name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
          mobilePriority: ios_app.mobile_priority,
          adSpend: ios_app.ios_fb_ad_appearances.present?,
          userBase: ios_app.user_base,
          lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released.to_s : nil,
          appStoreId: ios_app.app_identifier,
          iconLarge: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_350x350 : nil,
          iconSmall: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil,
          company: {
            name: company.present? ? company.name : nil,
            mightySignalId: company.present? ? company.id : nil,
            fortuneRank: company.present? ? company.fortune_1000_rank : nil,
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
      end
    rescue => e
      render json: json_failure
      merge_failure!(properties, app_json, e)
      track('ios_apps', properties)
      raise e
    else
      render json: app_json
      merge_success!(properties, app_json)
      track('ios_apps', properties)
    end

  end

  def android_apps
    begin
      app_identifier = params['googlePlayId']
      properties = {'app_identifier' => app_identifier.to_s}

      track('android_apps', 'app_identifier' => app_identifier.to_s)

      android_app = AndroidApp.find_by_app_identifier(app_identifier)

      if android_app.blank?
        app_json = {}
      else
        company = android_app.get_company
        newest_app_snapshot = android_app.newest_android_app_snapshot

        app_json = {
          mightySignalId: android_app.id,
          name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
          mobilePriority: android_app.mobile_priority,
          adSpend: android_app.android_fb_ad_appearances.present?,
          downloadsEstimate: newest_app_snapshot.present? ? (newest_app_snapshot.downloads_max -  newest_app_snapshot.downloads_min)/2.0 : nil,
          downloadsMin: newest_app_snapshot.present? ? newest_app_snapshot.downloads_min : nil,
          downloadsMax: newest_app_snapshot.present? ? newest_app_snapshot.downloads_max : nil,
          lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
          googlePlayId: android_app.app_identifier,
          iconLarge: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_300x300 : nil,
          company: {
            name: company.present? ? company.name : nil,
            mightySignalId: company.present? ? company.id : nil,
            fortuneRank: company.present? ? company.fortune_1000_rank : nil,
            websites: android_app.get_website_urls,
            location: {
              streetAddress: company.present? ? company.street_address : nil,
              city: company.present? ? company.city : nil,
              zipCode: company.present? ? company.zip_code : nil,
              state: company.present? ? company.state : nil,
              country: company.present? ? company.country : nil
            }
          }
        }
      end

    rescue => e
      render json: json_failure
      merge_failure!(properties, app_json, e)
      track('android_apps', properties)
      raise e
    else
      render json: app_json
      merge_success!(properties, app_json)
      track('android_apps', properties)
    end

  end

  def companies
    begin
      url = params['website']
      properties = {'website' => url.to_s}

      website = Website.find_by_url(url)

      if website.blank?
        company_h = {}
      else
        company = website.company

        company_h = {
          name: company.present? ? company.name : nil,
          mightySignalId: company.present? ? company.id : nil,
          fortuneRank: company.present? ? company.fortune_1000_rank : nil,
          location: {
            streetAddress: company.present? ? company.street_address : nil,
            city: company.present? ? company.city : nil,
            zipCode: company.present? ? company.zip_code : nil,
            state: company.present? ? company.state : nil,
            country: company.present? ? company.country : nil
          }
        }

        # jlew -- look at all sibling websites

        #ios_apps = IosAppsWebsite.where(website_id: website.id).map(&:ios_app_id).map{ |ios_app_id| IosApp.find(ios_app_id)}
        ios_apps = company.websites.map{ |website| website.ios_apps} #goes up to company, then down to all apps

        ios_apps_a = ios_apps.map do |ios_app|
          newest_app_snapshot = ios_app.newest_ios_app_snapshot

          {
            mightySignalId: ios_app.id,
            name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
            mobilePriority: ios_app.mobile_priority,
            adSpend: ios_app.ios_fb_ad_appearances.present?,
            userBase: ios_app.user_base,
            lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released.to_s : nil,
            appIdentifier: ios_app.app_identifier,
            appIconLarge: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_350x350 : nil,
            appIconSmall: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
          }
        end

        #android_apps = AndroidAppsWebsite.where(website_id: website.id).map(&:android_app_id).map{ |android_app_id| AndroidApp.find(android_app_id)}
        android_apps = company.websites.map{ |website| website.android_apps}  #goes up to company, then down to all apps

        android_apps_a = android_apps.map do |android_app|
          newest_app_snapshot = android_app.newest_android_app_snapshot

          {
            mightySignalId: android_app.id,
            name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
            mobilePriority: android_app.mobile_priority,
            adSpend: android_app.android_fb_ad_appearances.present?,
            downloadsEstimate: newest_app_snapshot.present? ? (newest_app_snapshot.downloads_max -  newest_app_snapshot.downloads_min)/2.0 : nil,
            downloadsMin: newest_app_snapshot.present? ? newest_app_snapshot.downloads_min : nil,
            downloadsMax: newest_app_snapshot.present? ? newest_app_snapshot.downloads_max : nil,
            lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
            googlePlayId: android_app.app_identifier,
            appIconLarge: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_300x300 : nil
          }
        end

        company_json = {company: company_h, apps: {ios_apps: ios_apps_a, android_apps: android_apps_a}}
      end

    rescue => e
      render json: json_failure
      merge_failure!(properties, company_json, e)
      track('companies', properties)
      raise e
    else
      render json: company_json
      merge_success!(properties, company_json)
      track('companies', properties)
    end

  end
  
  protected
  
  def merge_failure!(properties, response, exception)
    properties.merge!('status_code' => '500', 'exception' => {'message' => exception.message, 'backtrace' => exception.backtrace}, 'response' => response)
  end

  def merge_success!(properties, response)
    properties.merge!('status_code' => '400', 'response' => response)
  end
  
  def mixpanel_tracker
    key = request.headers[API_KEY_NAME]
    @tracker = Mixpanel::Tracker.new('8ffd3d066b34498a83b3230b899e9d50')
    
    api_key = ApiKey.find_by_key(key)
    account = api_key.account
    
    @account_id = account.id
    
    @tracker.people.set(account.id.to_s, {'name' => account.name, 'id' => @account_id}) 
  end
  
  def track(event, properties={}, ip=nil)
    return if Rails.env.development?
    
    @tracker.track(@account_id, event, properties, ip)
  end
  
  def json_failure
    {error: {code: 500, message: 'Internal Server Error'}}
  end

end
