require 'open-uri'
class ScrapeService

  def initialize
    @matchers = Matcher.all
  end

  def scrape(company)
    content = open(company.website).read
    result = ScrapedResult.create!(company: company, url: company.website, raw_html: content.truncate(1024), status: :success)
    matched_services = @matchers.select{|m| m.match?(content)}.map(&:service_id).uniq
    matched_services.each do |match|
      puts "found a match! #{company.name} is using #{match}"
      company.installations.create!(service_id: match, scraped_result: result)
    end
  rescue
    ScrapedResult.create(company: company, url: company.website, raw_html: $!.message.truncate(1024), status: :fail)
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
  end

end
