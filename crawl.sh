notes="unique notes"



notes="unique notes" &&  nohup bundle exec rake scraper:scrape_all SCRAPE_PERCENTAGE=50 SCRAPE_PAGE_NUMBER=0 SCRAPE_JOB_NOTES=notes RAILS_ENV=production > /dev/null 2>&1 & && nohup bundle exec rake scraper:scrape_all SCRAPE_PERCENTAGE=50 SCRAPE_PAGE_NUMBER=1 SCRAPE_JOB_NOTES=notes RAILS_ENV=production > /dev/null 2>&1 &