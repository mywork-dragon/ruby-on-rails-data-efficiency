class AppStoreInternationalAvailabilityWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :scraper_master

  def perform(new_store_updates = false)

    if new_store_updates
      puts "Updating all apps to available"
      IosApp.update_all(app_store_available: true) if new_store_updates
    end

    puts "Marking apps as unavailable"
    IosApp.joins('LEFT JOIN app_stores_ios_apps on ios_apps.id = app_stores_ios_apps.ios_app_id')
      .where('app_stores_ios_apps.id is NULL')
      .update_all(app_store_available: false)
  end
end
