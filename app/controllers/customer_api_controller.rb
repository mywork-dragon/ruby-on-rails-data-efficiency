# The controller for the API that we give to our customers
# Not to be confused with ApiController, which is our internal API to communicated with the frontend
# @author Jason Lew
class CustomerApiController < ApplicationController
  
  API_KEY_NAME = 'MightySignal-API-Key'
  
  skip_before_filter :verify_authenticity_token
  
  before_action :authenticate_request, except: [:ping]

  def authenticate_request
    key = request.headers[API_KEY_NAME]
    render json: {error: {code: 401, message: 'Unauthorized – Your API key is wrong.'}}, status: 401 if key.blank? || !ApiKey.find_by_key(key)
  end
  
  def ping
    render json: {success: true, server: 'api'}
  end

  def ios_apps
    key = request.headers[API_KEY_NAME]
    
    app_identifier = params['id']
    
    ios_app = IosApp.find_by_app_identifier(app_identifier)
    company = ios_app.get_company #could be nil, if no websites, or websites don't have company
    newest_app_snapshot = ios_app.newest_ios_app_snapshot
    newest_download_snapshot = ios_app.get_newest_download_snapshot
    app_json = {
      MightySignal_ID: ios_app.id,
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
  
  def android_apps
    key = request.headers[API_KEY_NAME]
    
    app_identifier = params['id']
    android_app = AndroidApp.find_by_app_identifier(app_identifier)
    company = android_app.get_company
    newest_app_snapshot = android_app.newest_android_app_snapshot
    
    app_json = {
      MightySignal_ID: android_app.id,
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
        MightySignal_ID: company.present? ? company.id : nil,
        fortuneRank: company.present? ? company.fortune_1000_rank : nil, 
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
  
  def companies
    key = request.headers[API_KEY_NAME]
    
    url = params['website']
    
    website = Website.find_by_url(url)
    
    company = website.company
    
    company_h = {
      name: company.present? ? company.name : nil,
      MightySignal_ID: company.present? ? company.id : nil,
      fortuneRank: company.present? ? company.fortune_1000_rank : nil, 
      funding: company.present? ? company.funding : nil,
      # websites: android_app.get_website_urls, #this is an array
      location: {
        streetAddress: company.present? ? company.street_address : nil,
        city: company.present? ? company.city : nil,
        zipCode: company.present? ? company.zip_code : nil,
        state: company.present? ? company.state : nil,
        country: company.present? ? company.country : nil
      }
    }
    
    ios_apps = IosAppsWebsite.where(website_id: website.id).map(&:ios_app_id).map{ |ios_app_id| IosApp.find(ios_app_id)}
    
    ios_apps_a = ios_apps.map do |ios_app|
      newest_app_snapshot = ios_app.newest_ios_app_snapshot
      
      {
        MightySignalID: ios_app.id,
        name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
        mobilePriority: ios_app.mobile_priority,
        adSpend: ios_app.ios_fb_ad_appearances.present?,
        userBase: ios_app.user_base,
        lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released.to_s : nil,
        appIdentifier: ios_app.app_identifier,
        appIcon: {
          large: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_350x350 : nil,
          small: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_175x175 : nil
        }
      }
    end
    
    android_apps = AndroidAppsWebsite.where(website_id: website.id).map(&:android_app_id).map{ |android_app_id| AndroidApp.find(android_app_id)}
    
    android_apps_a = android_apps.map do |android_app|
      newest_app_snapshot = android_app.newest_android_app_snapshot
      
      {
        MightySignal_ID: android_app.id,
        name: newest_app_snapshot.present? ? newest_app_snapshot.name : nil,
        mobilePriority: android_app.mobile_priority, 
        adSpend: android_app.android_fb_ad_appearances.present?, 
        countriesDeployed: nil, #not part of initial launch
        downloads: newest_app_snapshot.present? ? "#{newest_app_snapshot.downloads_min}-#{newest_app_snapshot.downloads_max}" : nil,
        lastUpdated: newest_app_snapshot.present? ? newest_app_snapshot.released : nil,
        appIdentifier: android_app.app_identifier,
        appIcon: {
          large: newest_app_snapshot.present? ? newest_app_snapshot.icon_url_300x300 : nil
        }
      }
    end
    
    company_json = {company: company_h, apps: {ios_apps: ios_apps_a, android_apps: android_apps_a}}
    
    render json: company_json
  end
  
  protected
  
  def mp_tracker(key)
    tracker = Mixpanel::Tracker.new('8ffd3d066b34498a83b3230b899e9d50')
    
    api_key = ApiKey.find_by_key('key')
    account = api_key.account
    
    tracker.people.set(account.id.to_s, {'name' => account.name, 'id', => account.id}) 
    
    tracker
  end

end
