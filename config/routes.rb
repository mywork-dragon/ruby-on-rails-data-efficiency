Rails.application.routes.draw do

  require 'sidekiq/web'
  require 'sidekiq/pro/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_UI_USERNAME'].to_s && password == ENV['SIDEKIQ_UI_PASSWORD'].to_s
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  root 'welcome#index'
  get 'apps/ios/:app_identifier' => 'welcome#ios_app_sdks'
  get 'apps/android/:app_identifier' => 'welcome#android_app_sdks'
  get 'top-ios-sdks' => 'welcome#top_ios_sdks', as: 'top-ios-sdks'
  get 'top-ios-apps' => 'welcome#top_ios_apps', as: 'top-ios-apps'
  get 'timeline' => 'welcome#timeline', as: 'timeline'
  get 'challenge' => 'challenge#index'
  get 'challenge/backend' => 'challenge#backend'
  get 'challenge/frontend' => 'challenge#frontend'
  get 'challenge/payment_seed' => 'challenge#payment_seed'

  get 'top-android-sdks' => 'welcome#top_android_sdks', as: 'top-android-sdks'
  get 'top-android-apps' => 'welcome#top_android_apps', as: 'top-android-apps'

  post 'subscribe' => 'welcome#subscribe', as: :subscribe
  post 'contact_us' => 'welcome#contact_us', as: :contact_us
  post 'try_it_out' => 'welcome#try_it_out', as: :try_it_out
  get '/privacy', to: redirect('/legal/privacy.pdf')

  match 'auth/:provider/callback', to: 'salesforce_sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'salesforce_sessions#destroy', as: 'signout', via: [:get, :post]

  post 'test_sf_post' => 'salesforce#test_sf_post'
  post 'test_get_token' => 'salesforce#test_get_token'
  post 'bizible_hydrate_lead' => 'bizible_salesforce#hydrate_lead'
  post 'bizible_hydrate_opp' => 'bizible_salesforce#hydrate_opp'
  get 'customer_salesforce_credentials' => 'customer_salesforce#salesforce_credentials'

  post 'triggermail_demo_hydrate_lead' => 'triggermail_demo_salesforce#hydrate_lead'
  post 'triggermail_hydrate_lead' => 'triggermail_salesforce#hydrate_lead'
  post 'lead_hydration_demo_hydrate_lead' => 'lead_hydration_demo_salesforce#hydrate_lead'

  get 'mturk' => 'mturk#gochime'

  # API Endpoints (for Front-End)
  post 'api/filter_ios_apps' => 'api#filter_ios_apps'
  post 'api/filter_android_apps' => 'api#filter_android_apps'
  post 'api/search/ios' => 'api#search_ios_apps'
  post 'api/search/android' => 'api#search_android_apps'
  post 'api/search/iosSdks' => 'api#search_ios_sdk'
  post 'api/search/androidSdks' => 'api#search_android_sdk'
  get 'api/search/export_to_csv' => 'api#export_results_to_csv'

  get 'api/get_ios_app' => 'api#get_ios_app'
  get 'api/get_android_app' => 'api#get_android_app'
  get 'api/get_company' => 'api#get_company'
  get 'api/get_ios_categories' => 'api#get_ios_categories'
  get 'api/get_android_categories' => 'api#get_android_categories'
  get 'api/download_fortune_1000_csv' => 'api#download_fortune_1000_csv'

  get 'api/get_ios_developer' => 'api#get_ios_developer'
  get 'api/get_android_developer' => 'api#get_android_developer'

  get 'api/newsfeed' => 'api#newsfeed'
  get 'api/newsfeed/details' => 'api#newsfeed_details'
  get 'api/newsfeed/export' => 'api#newsfeed_export'
  post 'api/newsfeed/follow' => 'api#newsfeed_follow'
  post 'api/newsfeed/add_country' => 'api#newsfeed_add_country'
  post 'api/newsfeed/remove_country' => 'api#newsfeed_remove_country'

  get 'api/ad_intelligence/ios' => 'api#ios_ad_intelligence'
  get 'api/ad_intelligence/android' => 'api#android_ad_intelligence'

  get 'api/list/get_lists' => 'api#get_lists'
  get 'api/list/get_list' => 'api#get_list'
  get 'api/list/export_to_csv' => 'api#export_list_to_csv'
  post 'api/list/create_new' => 'api#create_new_list'
  put 'api/list/add' => 'api#add_to_list'
  put 'api/list/add_mixed' => 'api#add_mixed_to_list'
  put 'api/list/delete_items' => 'api#delete_from_list'
  put 'api/list/delete' => 'api#delete_list'

  get 'api/sdk/android' => 'api#get_android_sdk'
  get 'api/sdk/ios' => 'api#get_ios_sdk'
  post 'api/sdk/:platform/tags' => 'api#update_sdk_tags'
  get 'api/sdk/autocomplete' => 'api#get_sdk_autocomplete'
  get 'api/sdk/scanned_count' => 'api#get_sdk_scanned_count'

  get 'api/location/autocomplete' => 'api#get_location_autocomplete'

  get 'api/export_newest_apps_chart_to_csv' => 'api#export_newest_apps_chart_to_csv'

  get 'api/test_timeout' => 'api#test_timeout'

  post 'api/contacts/export_to_csv' => 'api#export_contacts_to_csv'

  get 'api/results' => 'api#results'

  get 'api/user/tos' => 'api#user_tos_check'
  put 'api/user/tos' => 'api#user_tos_set'

  post 'api/company/contacts' => 'api#get_company_contacts'
  post 'api/company/contact' => 'api#get_contact_email'

  get 'api/custom_search' => 'api#custom_search'

  get 'api/chart/newest' => 'api#newest_apps_chart'
  get 'api/chart/export_to_csv' => 'api#export_newest_apps_chart_to_csv'

  get 'api/charts/top-android-apps' => 'api#top_android_apps'
  get 'api/charts/top-ios-apps' => 'api#top_ios_apps'
  get 'api/charts/ios-sdks' => 'api#ios_sdks'
  get 'api/charts/android-sdks' => 'api#android_sdks'
  get 'api/charts/ios-engagement' => 'api#ios_engagement'

  get 'api/tags' => 'api#tags'

  # get 'api/android_sdks' => 'api#android_sdks_for_app'
  # get 'api/android_sdks_exist' => 'api#android_sdks_for_app_exist'
  # get 'api/android_sdks_refresh' => 'api#android_sdks_for_app_refresh'

  get 'api/android_sdks_exist' => 'api#android_sdks_exist'
  get 'api/scan_android_sdks' => 'api#scan_android_sdks'
  get 'api/ios_sdks_exist' => 'api#ios_sdks_exist'
  post 'api/ios_start_scan' => 'api#ios_start_scan'
  get 'api/ios_scan_status' => 'api#ios_scan_status'
  post 'api/ios_reset_app_data' => 'api#ios_reset_app_data'

  get 'api/android_sdks_exist' => 'api#android_sdks_exist'
  post 'api/android_start_scan' => 'api#android_start_scan'
  get 'api/android_scan_status' => 'api#android_scan_status'

  get 'api/blog_feed' => 'api#blog_feed'

  namespace :api, defaults: {format: 'json'} do
    scope '/admin' do
      get '/' => 'admin#index'
      post 'update' => 'admin#update'
      post 'create_account' => 'admin#create_account'
      post 'create_user' => 'admin#create_user'
      post 'resend_invite' => 'admin#resend_invite'
      post 'unlink_accounts' => 'admin#unlink_accounts'
      post 'follow_sdks' => 'admin#follow_sdks'
      get 'export_to_csv' => 'admin#export_to_csv'
      get 'account_users' => 'admin#account_users'
      post 'ios_reset_app_data' => 'admin#ios_reset_app_data'
    end

    scope '/salesforce' do
      get 'search' => 'salesforce#search'
      post 'export' => 'salesforce#export'
    end

    scope '/saved_searches' do
      get 'get' => 'saved_searches#get_saved_searches'
      post 'create' => 'saved_searches#create_new_saved_search'
      put 'edit' => 'saved_searches#edit_saved_search'
      put 'delete' => 'saved_searches#delete_saved_search'
    end
  end

  # TODO: change from ewok to extension name
  get 'button/app_page' => 'ewok#ewok_app_page'

  # Auth Endpoints (for Front-End)
  post 'auth/login' => 'auth#authenticate'
  post 'auth/validate_token' => 'auth#validate_token'
  get 'auth/permissions' => 'auth#permissions'
  get 'auth/user/info' => 'auth#user_info'
  get 'auth/account/info' => 'auth#account_info'
  post 'auth/:provider', to: 'auth#authenticate_provider'

  # API for customers
  get 'ping' => 'customer_api#ping', constraints: { subdomain: 'api' }
  get 'ios_apps' => 'customer_api#ios_apps', constraints: { subdomain: 'api' }
  get 'android_apps' => 'customer_api#android_apps', constraints: { subdomain: 'api' }
  get 'companies' => 'customer_api#companies', constraints: { subdomain: 'api' }

  if Rails.env.development?
    get 'app_info' => 'app#app_info'
    get 'app_info_get_signals' => 'app#app_info_get_signals'
  end

  get 'ping' => 'application#ping'
  get 'companies' => 'results#companies'
  get 'services' => 'results#services'
  get 'company_result/:company_id' => 'results#company_result', as: :company_result
  get 'service_result/:service_id' => 'results#service_result', as: :service_result
  get 'url_search' => 'results#url_search'
  post 'url_search' => 'results#url_search_result', as: :url_search_result

  get 'fb-recruiting-privacy-policy' => 'privacy_policy#fb_recruiting'

  # internal api for FB account reservations
  put 'fb_account/reserve' => 'fb_account#reserve'
  put 'fb_account/release' => 'fb_account#release'

  put 'android_ad' => 'android_ad#create'
  post 'jobs/android/reclassify' => 'jobs#trigger_android_reclassification'

  post 'ios_sdk/new' => 'ios_sdk#create'
  post 'ios_sdk/validate' => 'ios_sdk#validate'
  get 'ios_sdk/query' => 'ios_sdk#athena_query'
end
