namespace 'scraper' do

  desc 'Scrape all companies'
  task :scrape_all => [:environment] do
    ScrapeService.scrape_all((ENV["SCRAPE_PERCENTAGE"] || 100).to_i, (ENV["SCRAPE_PAGE_NUMBER"] || 0).to_i)
  end
  
end