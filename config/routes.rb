Rails.application.routes.draw do

  root 'welcome#index'
  post 'contact_us' => 'welcome#contact_us', as: :contact_us
  post 'try_it_out' => 'welcome#try_it_out', as: :try_it_out
  
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
  post 'mighty_signal_hydrate_lead' => 'mighty_signal_salesforce#hydrate_lead'
  post 'mighty_signal_hydrate_opp' => 'mighty_signal_salesforce#hydrate_opp'
  
  get 'mturk' => 'mturk#gochime'
  
  # API Endpoints (for Front-End)
  post 'api/filter_ios_apps' => 'api#filter_ios_apps'
  post 'api/filter_android_apps' => 'api#filter_android_apps'
  get 'api/get_ios_app' => 'api#get_ios_app'
  get 'api/get_android_app' => 'api#get_android_app'
  get 'api/get_company' => 'api#get_company'
  get 'api/get_ios_categories' => 'api#get_ios_categories'
  get 'api/get_android_categories' => 'api#get_android_categories'
  get 'api/download_fortune_1000_csv' => 'api#download_fortune_1000_csv'
  get 'api/search/export_results_to_csv' => 'api#export_all_search_results_to_csv'

  get 'api/list/get_lists' => 'api#get_lists'
  get 'api/list/get_list' => 'api#get_list'
  get 'api/list/export_to_csv' => 'api#export_list_to_csv'
  post 'api/list/create_new' => 'api#create_new_list'
  put 'api/list/add' => 'api#add_to_list'
  put 'api/list/add_mixed' => 'api#add_mixed_to_list'
  put 'api/list/delete_items' => 'api#delete_from_list'
  put 'api/list/delete' => 'api#delete_list'

  post 'api/contacts/export_to_csv' => 'api#export_contacts_to_csv'

  get 'api/results' => 'api#results'

  get 'api/user/tos' => 'api#user_tos_check'
  put 'api/user/tos' => 'api#user_tos_set'

  post 'api/company/contacts' => 'api#get_company_contacts'

  get 'api/custom_search' => 'api#custom_search'

  get 'api/chart/newest' => 'api#newest_apps_chart'
  get 'api/chart/export_to_csv' => 'api#export_newest_apps_chart_to_csv'

  get 'api/android_sdks' => 'api#android_sdks_for_app'
  get 'api/android_sdks_exist' => 'api#android_sdks_for_app_exist'
  get 'api/android_sdks_refresh' => 'api#android_sdks_for_app_refresh'

  # Auth Endpoints (for Front-End)
  post 'auth/login' => 'auth#authenticate'
  post 'auth/validate_token' => 'auth#validate_token'
  get 'auth/permissions' => 'auth#permissions'

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
  
  # require 'sidekiq/web'
  # mount Sidekiq::Web => '/sidekiq'
  
end
