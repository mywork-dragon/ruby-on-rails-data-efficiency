namespace 'scraper' do

  desc 'Create scrape job'
  task :create_scrape_job => [:environment] do
    ScrapeService.create_scrape_job(ENV["SCRAPE_JOB_NOTES"])
  end

  desc 'Scrape all companies'
  task :scrape_all => [:environment] do
    ScrapeService.scrape_all((ENV["SCRAPE_PROCESSES"] || 100).to_i, (ENV["SCRAPE_PAGE_NUMBER"] || 0).to_i, ENV["SCRAPE_JOB_NOTES"], source_only: ENV["SOURCE_ONLY"]=="true")
  end
  
  desc 'Scrape some companies'
  task :scrape_some => [:environment] do
    ScrapeService.scrape_some(ENV["SCRAPE_COUNT"].to_i, (ENV["SCRAPE_PROCESSES"] || 100).to_i, (ENV["SCRAPE_PAGE_NUMBER"] || 0).to_i, ENV["SCRAPE_JOB_NOTES"], source_only: ENV["SOURCE_ONLY"]=="true")
  end
  
  desc 'Scrape for Bizible Job 2'
  task :scrape_bizible_job2 => [:environment] do
    BizibleJob2.scrape_all((ENV["SCRAPE_PROCESSES"]).to_i, (ENV["SCRAPE_PAGE_NUMBER"]).to_i, ENV["SCRAPE_JOB_NOTES"], source_only: ENV["SOURCE_ONLY"]=="true")
  end
  
  
  desc 'Scrape special'
  task :scrape_special => [:environment] do
    puts "scrape special task"
    ScrapeService.scrape_special()
  end
  
  desc 'Scrape AngelList'
  task :scrape_angellist => [:environment] do
    SpidrService.run_angellist
  end
  
  desc 'Add Alexa Companies'
  task :add_alexa => [:environment] do
    AlexaService.run("/home/webapps/varys/current/db/alexa/top-1m_10_21_14_short.csv")
  end
  
  desc 'MightySignalSalesforceService.hydrate_all_leads'
  task :hal => [:environment] do
    MightySignalSalesforceService.hydrate_all_leads
  end
  
  desc 'BizibleSalesforceService.hydrate_opportunities'
  task :bizible_all_opps => [:environment] do
    BizibleSalesforceService.hydrate_opportunities
  end
  
  
end