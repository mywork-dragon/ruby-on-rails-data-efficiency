class AddAllIosAppsToUsServiceWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(app_ids)
    
    us_app_store = AppStore.find_by_country_code('us')
    
    app_ids.each do |app_id|
      ios_app = IosApp.find(app_id)
      ios_app.app_stores << us_app_store
    end
    

  end