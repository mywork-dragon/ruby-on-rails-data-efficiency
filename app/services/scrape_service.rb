require 'open-uri'
class ScrapeService

  def initialize
    @matchers = Matcher.all
  end

  def scrape(company)
    # allow http to https and https to http redirections
    content = open(company.website, 
      allow_redirections: :all,
      # hong's own user agent in chrome, you should probably fake the one from IE
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.122 Safari/537.36"
    ).read

    # check the content's encoding and force it to utf8, discard the invalid characters in utf-8
    content.force_encoding(Encoding::UTF_8)
    if !content.valid_encoding?
      content.encode!(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '')
    end

    result = ScrapedResult.create!(company: company, url: company.website, raw_html: content.truncate(1024), status: :success)
    matched_service = matched_services_in_content(content)
    matched_services.each do |match|
      puts "found a match! #{company.name} is using #{match}"
      company.installations.create!(service_id: match, scraped_result: result)
    end
  rescue Exception => e
    if e.message.include?("getaddrinfo: nodename nor servname provided, or not known") ||
        e.message.include?("404 Not Found")
      # this means we can't reach the server at all, we should probably pause the company
      company.paused!
    end
    ScrapedResult.create(company: company, url: company.website, raw_html: e.message.truncate(1024), status: :fail)
  end
  
  # Scrape a single URL and don't save the results to the DB
  # @author Jason Lew
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
      Company.active.find_each do |c|
        begin
          puts "scraping company #{c.name}"
          scrape_service.scrape(c)
        rescue
          puts "failed to scrape company #{c.name}, strange huh? #{$!.message}"
          pp $!.backtrace
        end
      end
    end

    def scrape(company)
      ScrapeService.new.scrape(company)
    end
    
    # Scrape a single URL and don't save the results to the DB
    # @author Jason Lew
    def scrape_test(url)
      ScrapeService.new.scrape_test(url)
    end
  end

end
