Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get '/team', to: 'welcome#team'
  post 'contact_us' => 'welcome#contact_us', as: :contact_us
  post 'try_it_out' => 'welcome#try_it_out', as: :try_it_out
  
  # get 'demo' => 'welcome#demo'
  # post 'submit_demo' => "welcome#submit_demo"
  #
  # get 'demo_you_are' => 'welcome#demo_you_are'
  # get 'demo3' => 'welcome#demo3'
  # get 'demo4' => 'welcome#demo4'
  # get 'demo_services' => 'welcome#demo_services'
  # get 'demo_companies' => 'welcome#demo_companies'
  # get 'demo_get_services' => 'welcome#demo_get_services'
  # get 'demo_get_companies' => 'welcome#demo_get_companies'
  
  match 'auth/:provider/callback', to: 'salesforce_sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'salesforce_sessions#destroy', as: 'signout', via: [:get, :post]
  
  post 'test_sf_post' => 'salesforce#test_sf_post'
  post 'test_get_token' => 'salesforce#test_get_token'
  post 'bizible_hydrate_lead'=> 'bizible_salesforce#hydrate_lead'
  post 'bizible_hydrate_opp'=> 'bizible_salesforce#hydrate_opp'
  get 'customer_salesforce_credentials' => 'customer_salesforce#salesforce_credentials'
  
  post 'triggermail_demo_hydrate_lead'=> 'triggermail_demo_salesforce#hydrate_lead'
  
  post 'triggermail_hydrate_lead'=> 'triggermail_salesforce#hydrate_lead'
  
  post 'lead_hydration_demo_hydrate_lead'=> 'lead_hydration_demo_salesforce#hydrate_lead'
  
  post 'mighty_signal_hydrate_lead'=> 'mighty_signal_salesforce#hydrate_lead'
  post 'mighty_signal_hydrate_opp'=> 'mighty_signal_salesforce#hydrate_opp'
  
  get 'mturk' => 'mturk#gochime'
  
  #api for endpoints
  post 'api/filter_ios_apps' => 'api#filter_ios_apps'
  post 'api/filter_android_apps' => 'api#filter_android_apps'
  get 'api/get_ios_app' => 'api#get_ios_app'
  get 'api/get_android_app' => 'api#get_android_app'
  get 'api/get_company' => 'api#get_company'
  get 'api/get_ios_categories' => 'api#get_ios_categories'
  get 'api/get_android_categories' => 'api#get_android_categories'
  get 'api/download_fortune_1000_csv' => 'api#download_fortune_1000_csv'

  get 'api/list/get_lists' => 'api#get_lists'
  get 'api/list/get_list' => 'api#get_list'
  get 'api/list/export_to_csv' => 'api#export_list_to_csv'
  post 'api/list/create_new' => 'api#create_new_list'
  put 'api/list/add' => 'api#add_to_list'
  put 'api/list/delete_items' => 'api#delete_from_list'
  put 'api/list/delete' => 'api#delete_list'
  get 'api/results' => 'api#results'
  
  # API for customers
  get 'ping' => 'customer_api#ping', constraints: { subdomain: 'api' }
  get 'ios_apps' => 'customer_api#ios_apps', constraints: { subdomain: 'api' }
  get 'android_apps' => 'customer_api#android_apps', constraints: { subdomain: 'api' }
  get 'companies' => 'customer_api#companies', constraints: { subdomain: 'api' }
  get 'companies2' => 'customer_api#companies2', constraints: { subdomain: 'api' }

  
  if Rails.env.development?
    get 'app_info' => 'app#app_info'
    get 'app_info_get_signals' => 'app#app_info_get_signals'
  end
  
  post 'auth/login' => 'auth#authenticate'
  post 'auth/validate_token' => 'auth#validate_token'
  
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  get 'ping' => 'application#ping'
  get 'companies' => 'results#companies'
  get 'services' => 'results#services'
  get 'company_result/:company_id' => 'results#company_result', as: :company_result
  get 'service_result/:service_id' => 'results#service_result', as: :service_result
  get 'url_search' => 'results#url_search'
  post 'url_search' => 'results#url_search_result', as: :url_search_result
  
end
