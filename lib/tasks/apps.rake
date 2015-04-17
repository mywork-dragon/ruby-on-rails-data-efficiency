namespace 'apps' do

  desc 'Add iOS apps'
  task :add_ios_apps => [:environment] do
    AppStoreIdsService.scrape_app_store
  end
  
  desc 'Ad Heroku transfer CSV'
  task :ad_heroku_transfer_csv => [:environment] do
    AdHerokuTransfer.create_csv
  end
  
  # desc 'Snapshot iOS apps'
  # task :snapshot_ios_apps => [:environment] do
  #   AppStoreSnapshotService.run
  # end
  
end