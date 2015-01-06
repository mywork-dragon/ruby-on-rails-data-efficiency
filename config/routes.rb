Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get '/team', to: 'welcome#team'
  post 'contact_us' => 'welcome#contact_us', as: :contact_us
  post 'try_it_out' => 'welcome#try_it_out', as: :try_it_out
  
  get 'demo' => 'welcome#demo'
  post 'submit_demo' => "welcome#submit_demo"
  
  get 'demo_you_are' => 'welcome#demo_you_are'
  get 'demo3' => 'welcome#demo3'
  get 'demo4' => 'welcome#demo4'
  get 'demo_services' => 'welcome#demo_services'
  get 'demo_companies' => 'welcome#demo_companies'
  get 'demo_get_services' => 'welcome#demo_get_services'
  get 'demo_get_companies' => 'welcome#demo_get_companies'
  
  match 'auth/:provider/callback', to: 'salesforce_sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'salesforce_sessions#destroy', as: 'signout', via: [:get, :post]
  
  post 'test_sf_post' => 'salesforce#test_sf_post'
  post 'test_get_token' => 'salesforce#test_get_token'
  post 'bizible_hydrate_lead'=> 'bizible_salesforce#hydrate_lead'
  post 'bizible_hydrate_opp'=> 'bizible_salesforce#hydrate_opp'
  get 'bizible_salesforce_credentials' => 'bizible_salesforce#salesforce_credentials'
  
  post 'triggermail_demo_hydrate_lead'=> 'triggermail_demo_salesforce#hydrate_lead'
  
  post 'mighty_signal_hydrate_lead'=> 'mighty_signal_salesforce#hydrate_lead'
  post 'mighty_signal_hydrate_opp'=> 'mighty_signal_salesforce#hydrate_opp'
  
  get 'mturk' => 'mturk#gochime'
  
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
