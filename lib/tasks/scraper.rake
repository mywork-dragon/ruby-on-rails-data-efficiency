namespace 'scraper' do

  desc 'Scrape App Store'
  task scrape_app_store: [:environment] do |task|
    AppStoreSnapshotService.run
  end

  desc 'Scrape Google Play'
  task scrape_google_play: [:environment] do |task|
    GooglePlaySnapshotService.run
  end 

  
  
end