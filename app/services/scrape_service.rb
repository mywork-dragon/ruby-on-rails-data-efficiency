require 'open-uri'
class ScrapeService

  def initialize
    @matchers = Matcher.all
  end

  def scrape(company)
    content = open(company.website).read
    result = ScrapedResult.create!(company: company, url: company.website, raw_html: content.truncate(1024), status: :success)
    matched_service = matched_services_in_content(content)
    matched_services.each do |match|
      puts "found a match! #{company.name} is using #{match}"
      company.installations.create!(service_id: match, scraped_result: result)
    end
  rescue
    ScrapedResult.create(company: company, url: company.website, raw_html: $!.message.truncate(1024), status: :fail)
  end
  
  def scrape_test(url)
    content = open(url).read
    service_names = []
    matched_services_in_content(content).each do |match|
      service_name = Service.find(match).name
      puts "found a match! #{url} is using #{service_name}"
      service_names << service_name
    end
    
    service_names
  end
  
  private
  
    def matched_services_in_content(content)
      @matchers.select{|m| m.match?(content)}.map(&:service_id).uniq
    end
  

  class << self
    def scrape_all
      scrape_service = ScrapeService.new
      Company.all.each do |c|
        puts "scraping company #{c.name}"
        scrape_service.scrape(c)
      end
    end

    def scrape(company)
      ScrapeService.new.scrape(company)
    end
    
    def scrape_test(url)
      ScrapeService.new.scrape_test(url)
    end
  end

end
