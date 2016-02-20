# cd varys_current && nohup bundle exec rake scraper:scrape_whatever RAILS_ENV=production > ~/scraper.log 2>&1 &

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