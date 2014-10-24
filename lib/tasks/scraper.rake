namespace 'scraper' do

  desc 'Scrape all companies'
  task :scrape_all => [:environment] do
    ScrapeService.scrape_all((ENV["SCRAPE_PROCESSES"] || 100).to_i, (ENV["SCRAPE_PAGE_NUMBER"] || 0).to_i, ENV["SCRAPE_JOB_NOTES"])
  end
  
  desc 'Scrape some companies'
  task :scrape_some => [:environment] do
    ScrapeService.scrape_some(ENV["SCRAPE_COUNT"], (ENV["SCRAPE_PROCESSES"] || 100).to_i, (ENV["SCRAPE_PAGE_NUMBER"] || 0).to_i, ENV["SCRAPE_JOB_NOTES"])
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
  
  
end