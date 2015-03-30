class AppStoreIdsServiceWorker
  include Sidekiq::Worker
  
  def perform(ios_app_snap)
  end
  
end