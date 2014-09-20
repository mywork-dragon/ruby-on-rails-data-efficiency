namespace 'scraper' do

  desc 'Scrape all companies'
  task :scrape_all => [:environment] do
    ScrapeService.scrape_all
  end
  
end