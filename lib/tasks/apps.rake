namespace 'apps' do

  desc 'Add iOS apps'
  task :add_ios_apps => [:environment] do
    AppStoreIdsService.scrape_app_store
  end
  
end