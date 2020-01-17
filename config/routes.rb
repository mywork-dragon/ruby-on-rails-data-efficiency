Rails.application.routes.draw do

  namespace :blog, :as => 'buttercms', :module => 'buttercms' do
    get 'rss' => 'feeds#rss', :format => 'rss', :as => :rss
    get 'atom' => 'feeds#atom', :format => 'atom', :as => :atom
    get 'sitemap.xml' => 'feeds#sitemap', :format => 'xml', :as => :sitemap

    get 'case-studies(/page/:page)' => 'case_studies#index', :defaults => {:page => 1}, :as => :case_studies
    get 'case-studies/:slug' => 'case_studies#show', :as => :case_study

    get '(/page/:page)' => 'posts#index', :defaults => {:page => 1}, :as => :posts
    get ':slug' => 'posts#show', :as => :post
  end

  get 'ping' => 'application#ping'

  constraints lambda { |req| req.subdomain != 'api' }  do

    require 'sidekiq/web'
    require 'sidekiq/pro/web'
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == ENV['SIDEKIQ_UI_USERNAME'].to_s && password == ENV['SIDEKIQ_UI_PASSWORD'].to_s
    end if Rails.env.production?
    mount Sidekiq::Web, at: "/sidekiq"

    root 'welcome#index'
    get 'apps/ios/:app_identifier' => 'welcome#ios_app_sdks'
    get 'apps/android/:app_identifier' => 'welcome#android_app_sdks'
    get 'a/:platform/:app_identifier(/:app_name)' => 'welcome#app_page', constraints: { platform: /(google-play|ios)/, app_identifier: /[a-zA-Z0-9_.]+/ }, as: 'app_page'
    get 'sdk/:platform/:sdk_id(/:sdk_name)' => 'welcome#sdk_page', as: 'sdk_page' 
    get 'sdk-directory(/:platform)(/:letter)(/:page)' => 'welcome#sdk_directory', as: 'sdk_directory'
    get 'sdk-category/:category_id(/:category)' => 'welcome#sdk_category_page', as: 'sdk_category_page'
    get 'sdk-category-directory' => 'welcome#sdk_category_directory', as: 'sdk_category_directory'
    get 'sdk-category-directory/sdks/:category_id(/:category)' => 'welcome#sdk_category_directory_sdks', as: 'sdk_category_directory_sdks'
    get 'top-ios-sdks' => 'welcome#top_ios_sdks', as: 'top-ios-sdks'
    get 'top-ios-apps' => 'welcome#top_ios_apps', as: 'top-ios-apps'
    get 'timeline' => 'welcome#timeline', as: 'timeline'
    get 'challenge' => 'challenge#index'
    get 'challenge/backend' => 'challenge#backend'
    get 'challenge/frontend' => 'challenge#frontend'
    get 'challenge/payment_seed' => 'challenge#payment_seed'
    get 'mighty_report' => 'mighty_report#index'
    post 'get_mighty_report' => 'mighty_report#get_report', as: :get_report
    get 'welcome/sdk/icon/:platform/:id' => 'welcome#get_sdk_icon'
    get 'welcome/search_apps' => 'welcome#search_apps'

    get 'fastest-growing-android-sdks' => 'fastest_growing_sdks#top_install_base', as: 'fastest-growing-android-sdks'
    get 'fastest-growing-android-sdks-blog-post' => 'fastest_growing_sdks#blog_post_redirect', as: 'fastest-growing-android-sdks-blog-post'

    get 'top-android-sdks' => 'welcome#top_android_sdks', as: 'top_android_sdks'
    get 'top-android-apps' => 'welcome#top_android_apps', as: 'top_android_apps'

    get 'fastest-growing-sdks' => 'welcome#fastest_growing_sdks', as: 'fastest-growing-sdks'

    get 'data' => 'welcome#data'
    get 'publisher-contacts' => 'welcome#publisher_contacts'
    get 'web-portal' => 'welcome#web_portal'
    get 'the-api' => 'welcome#the_api', as: 'the-api'
    get 'data-feed' => 'welcome#data_feed', as: 'data-feed'
    get 'salesforce-integration' => 'welcome#salesforce_integration', as: 'salesforce-integration'

    get 'lead-generation' => 'welcome#lead_generation', as: 'lead-generation'
    get 'abm' => 'welcome#abm', as: 'abm'
    get 'sdk-intelligence' => 'welcome#sdk_intelligence', as: 'sdk-intelligence'
    get 'user-acquisition' => 'welcome#user_acquisition', as: 'user-acquisition'
    get 'lead-generation-ad-affiliate-networks' => 'welcome#lead_generation_ad_affiliate_networks', as: 'lead-generation-ad-affiliate-networks'

    get 'well-be-in-touch' => 'welcome#well_be_in_touch', as: 'well-be-in-touch'

    post 'subscribe' => 'welcome#subscribe', as: :subscribe
    post 'contact_us' => 'welcome#contact_us', as: :contact_us
    post 'try_it_out' => 'welcome#try_it_out', as: :try_it_out
    get 'privacy' => 'welcome#privacy', as: :privacy

    get 'coding-challenge', to: redirect('https://mightysignal.github.io/coding-challenge-directions/')

    match 'auth/:provider/callback', to: 'salesforce_sessions#create', via: [:get, :post]
    match 'auth/failure', to: redirect('/'), via: [:get, :post]
    match 'signout', to: 'salesforce_sessions#destroy', as: 'signout', via: [:get, :post]

    # API Endpoints (for Front-End)
    get 'api/app_status' => 'api#check_app_status'
    post 'api/filter_ios_apps' => 'api#filter_ios_apps'
    post 'api/filter_android_apps' => 'api#filter_android_apps'
    post 'api/search/apps' => 'api#search_apps'
    post 'api/search/sdks' => 'api#search_sdks'
    get 'api/search/export_to_csv' => 'api#export_results_to_csv'

    get 'api/get_ios_app' => 'api#get_ios_app'
    get 'api/get_android_app' => 'api#get_android_app'
    get 'api/get_company' => 'api#get_company'
    get 'api/get_ios_categories' => 'api#get_ios_categories'
    get 'api/get_android_categories' => 'api#get_android_categories'
    get 'api/ranking_countries' => 'api#get_ranking_countries'
    get 'api/android_category_objects' => 'api#get_android_category_objects'
    get 'api/ios_category_objects' => 'api#get_ios_category_objects'
    get 'api/download_fortune_1000_csv' => 'api#download_fortune_1000_csv'
    get 'api/get_ios_sdk_categories' => 'api#get_ios_sdk_categories'
    get 'api/get_android_sdk_categories' => 'api#get_android_sdk_categories'

    get 'api/get_ios_developer' => 'api#get_ios_developer'
    get 'api/get_android_developer' => 'api#get_android_developer'
    get 'api/get_developer_apps' => 'api#get_developer_apps'

    get 'api/newsfeed' => 'api#newsfeed'
    get 'api/newsfeed/details' => 'api#newsfeed_details'
    get 'api/newsfeed/export' => 'api#newsfeed_export'
    post 'api/newsfeed/follow' => 'api#newsfeed_follow'
    post 'api/newsfeed/add_country' => 'api#newsfeed_add_country'
    post 'api/newsfeed/remove_country' => 'api#newsfeed_remove_country'

    post 'api/mightyquery_auth' => 'api#mightyquery_auth_token'

    # Ad intel v2 routes
    get 'api/ad_intelligence/v2/query' => 'ad_intelligence#ad_intelligence_query'
    get 'api/ad_intelligence/v2/ad_sources' => 'ad_intelligence#available_sources'
    get 'api/ad_intelligence/v2/creatives' => 'ad_intelligence#creatives'
    get 'api/ad_intelligence/v2/app_summaries' => 'ad_intelligence#ad_intel_app_summaries'
    get 'api/ad_intelligence/v2/publisher_creatives' => 'ad_intelligence#ad_intel_publisher_creatives'
    get 'api/ad_intelligence/v2/publisher_summary' => 'ad_intelligence#ad_intel_app_summaries'
    get 'api/ad_intelligence/v2/account_settings' => 'ad_intelligence#get_account_settings'
    put 'api/ad_intelligence/v2/update_account_settings' => 'ad_intelligence#update_account_settings'

    get 'api/ad_intelligence/ios' => 'api#ios_ad_intelligence'
    get 'api/ad_intelligence/android' => 'api#android_ad_intelligence'
    get 'api/ad_intelligence/all' => 'api#combined_ad_intelligence'
    get 'api/new_advertiser_counts' => 'api#new_advertiser_counts'
    get 'api/export_new_advertisers' => 'api#new_advertisers_csv'

    get 'api/sdk/android' => 'api#get_android_sdk'
    get 'api/sdk/ios' => 'api#get_ios_sdk'
    post 'api/sdk/:platform/tags' => 'api#update_sdk_tags'
    get 'api/sdk/autocomplete' => 'api#get_sdk_autocomplete'
    get 'api/sdks/autocomplete/v2' => 'api#get_sdks_autocomplete_v2'
    get 'api/sdk/scanned_count' => 'api#get_sdk_scanned_count'

    get 'api/location/autocomplete' => 'api#get_location_autocomplete'

    get 'api/export_newest_apps_chart_to_csv' => 'api#export_newest_apps_chart_to_csv'

    get 'api/test_timeout' => 'api#test_timeout'

    post 'api/contacts/export_to_csv' => 'api#export_contacts_to_csv'

    post 'api/contacts/start_export_to_csv' => 'api#export_contacts_to_csv_by_domains'

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
        get 'get_api_tokens' => 'admin#get_api_tokens'
        post 'generate_api_token' => 'admin#generate_api_token'
        put 'delete_api_token' => 'admin#delete_api_token'
        post 'update_api_token' => 'admin#update_api_token'
        post 'major_apps/tag' => 'admin#tag_major_app'
        put 'major_apps/untag' => 'admin#untag_major_app'
        post 'major_publishers/tag' => 'admin#tag_major_publisher'
        put 'major_publishers/untag' => 'admin#untag_major_publisher'
        get 'users' => 'admin#users_list'
      end

      scope '/salesforce' do
        get 'search' => 'salesforce#search'
        post 'export' => 'salesforce#export'
      end

      scope '/popular_apps' do
        get 'trending' => 'popular_apps#trending'
        get 'newcomers' => 'popular_apps#newcomers'
        get 'top_app_chart' => 'popular_apps#top_app_chart'
      end

      scope '/saved_searches' do
        get 'get' => 'saved_searches#get_saved_searches'
        post 'create' => 'saved_searches#create_new_saved_search'
        put 'edit' => 'saved_searches#edit_saved_search'
        put 'delete' => 'saved_searches#delete_saved_search'
      end

      scope '/list' do
        get 'get_lists' => 'lists#get_lists'
        get 'get_list' => 'lists#get_list'
        get 'export_to_csv' => 'lists#export_list_to_csv'
        post 'create_new' => 'lists#create_new_list'
        put 'add' => 'lists#add_to_list'
        put 'delete_items' => 'lists#delete_from_list'
        put 'delete' => 'lists#delete_list'
      end

      scope '/historical_app_rankings' do
        get 'get_app_rankings' => 'historical_app_rankings#get_historical_app_rankings'
      end

      scope 'itunes_charts_rankings' do
        get 'request_charts_rankings' => 'itunes_charts_rankings#request_charts_rankings'
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

    get 'fb-recruiting-privacy-policy' => 'privacy_policy#fb_recruiting'

    # internal api for FB account reservations
    put 'fb_account/reserve' => 'fb_account#reserve'
    put 'fb_account/release' => 'fb_account#release'

    # internal api to revtrieve info about the
    # devices in the lab
    get 'ios_devices' => 'ios_device#filter'
    get 'ios_devices/fb_accounts' => 'ios_device#get_device_fb_accounts'
    get 'ios_devices/device_email' => 'ios_device#get_device_apple_account_email'
    put 'ios_devices/enable' => 'ios_device#enable_device'
    put 'ios_devices/disable' => 'ios_device#disable_device'

    # Internal api to upload ios facebook ads for processsing
    post 'ios_fb_ads/new' => 'ios_fb_ads#upload_ad'
    post 'ios_fb_ad_job/new' => 'ios_fb_ads#create_scrape_job'
    post 'ios_fb_ads/process' => 'ios_fb_ads#start_processing'

    # Internal api to retrieve ranking category data
    get 'android_ranking_categories' => 'rankings#get_android_category_objects'
    get 'ios_ranking_categories' => 'rankings#get_ios_category_objects'

    put 'android_ad' => 'android_ad#create'
    post 'jobs/android/reclassify' => 'jobs#trigger_android_reclassification'
    post 'jobs/ios/reclassify' => 'jobs#trigger_ios_reclassification'

    # internal api for v2 of ios download system
    put '/ios_download/download/:varys_cd_id' => 'ios_download#update'
    put '/ios_download/set_ipa_snapshot_status/:varys_cd_id' => 'ios_download#set_ipa_snapshot_status'

    # DEPRECATED
    # post 'ios_sdk/new' => 'ios_sdk#create'
    # post 'ios_sdk/validate' => 'ios_sdk#validate'
    post 'ios_sdk/sync' => 'ios_sdk#sync'

    put 'epf/incremental' => 'epf#load_incremental'
    put 'epf/full' => 'epf#load_full'
  end

  # Client-facing API
  constraints subdomain: ['api', 'staging.api'] do
    scope module: 'client_api' do
      get '/', to: redirect('/docs', status: 302)

      # app
      get 'ios/app' => 'ios_app#filter'
      get 'android/app' => 'android_app#filter'
      get 'ios/app/:app_identifier' => 'ios_app#show'

      get 'android/app_classes/:id' => 'android_app#show_classes'
      get 'ios/app_classes/:id' => 'ios_app#show_classes'

      get(
        'android/app/:app_identifier',
        to: 'android_app#show',
        constraints: { app_identifier: /[\w\.]+/ } # com.ubercab
      )

      # sdk
      get 'ios/sdk/:id' => 'ios_sdk#show'
      get 'android/sdk/:id' => 'android_sdk#show'

      # publisher
      get 'ios/publisher' => 'ios_publisher#filter'
      get 'ios/publisher/:id' => 'ios_publisher#show'
      get 'android/publisher' => 'android_publisher#filter'
      get 'android/publisher/:id' => 'android_publisher#show'

      # Contacts
      get 'ios/publisher/:publisher_id/contacts' => 'ios_publisher#contacts'
      get 'android/publisher/:publisher_id/contacts' => 'android_publisher#contacts'

      # misc
      get 'app_company' => 'app_companies#show'
      get 'rate-limit' => 'rate_limit#show'
    end
  end

  get '404' => 'error#not_found', :via => :all
  get '500' => 'error#internal_error', :via => :all
end
