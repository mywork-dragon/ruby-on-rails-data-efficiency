namespace 'apps' do

  desc 'Add iOS apps'
  task :add_ios_apps => [:environment] do
    AppStoreIdsService.scrape_app_store
  end
  
  desc 'Ad Heroku transfer CSV'
  task :ad_heroku_transfer_csv => [:environment] do
  end
  
end