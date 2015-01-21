require 'open-uri'
require 'timeout'

class ScrapeService

  def initialize(options = {})
    @matchers = Matcher.all
    @services = Service.all
    
    @scrape_job = options[:scrape_job]
  end

  def scrape(company, options = {})
    website = company.website

    content = nil
    
    if options[:source_only]
      content = content_from_source(website).first
    else
      content = content_from_source_and_headless_browser(website)
    end
    
    
    #puts "content: #{content}"
    
    company_id = company.id
    scrape_job_id = @scrape_job.id if @scrape_job 
      
    if content.nil?
      #puts "content is nil"
      ScrapedResult.create!(company_id: company_id, url: website, raw_html: "Error: Could not connect to site", scrape_job_id: scrape_job_id,  status: :fail)
      return
    end

    result = ScrapedResult.create!(company_id: company_id, url: website, scrape_job_id: scrape_job_id, status: :success)
    
    # result = nil
    
    # begin
    #   # store raw scrape result
    #   # result = ScrapedResult.create!(company_id: company_id, url: website, raw_html: content.truncate(1024), scrape_job_id: scrape_job_id, status: :success)
    #   result = ScrapedResult.create!(company_id: company_id, url: website, raw_html: "", scrape_job_id: scrape_job_id, status: :success)
    # rescue Exception => e
    #   if e.message.include?("Mysql2::Error: Incorrect string value")
    #    result = ScrapedResult.create!(company_id: company_id, url: website, raw_html: "Error: Mysql2::Error: Incorrect string value", scrape_job_id: scrape_job_id, status: :success)
    #   end
    # end

    # stored matched services from matcher
    matched_services = matched_services_in_content(content)
    matched_services.each do |match|
      puts "found a match! #{company.name} is using #{match}"
      company.installations.create!(service_id: match, scraped_result: result, scrape_job: @scrape_job, status: :confirmed)
    end

    # now look for possible matches from just name
    # @services.select{|x| !matched_services.include?(x.id) && x.possible_match?(content)}.each do |possible_match|
    #   puts "found a possible match! #{company.name} is using #{possible_match.name}"
    #   company.installations.create!(service: possible_match, scraped_result: result, status: :possible)
    # end
    
    matched_services
  end
  
  # Scrape a single URL and don't save the results to the DB
  # @author Jason Lew
  def scrape_without_save(url)
    content = content_from_source_and_headless_browser(url)
    
    # puts "***CONTENT***\n#{content}"
    
    if content.blank?
      puts "Error: No Content"
      return []
    end
    
    service_names = []
    matched_services_in_content(content).each do |match|
      service_name = Service.find(match).name
      puts "found a match! #{url} is using #{service_name}"
      service_names << service_name
    end
    
    service_names.sort_by{|word| word.downcase}
  end
  
  def content_from_source_and_headless_browser(url)
    content_from_source, url_redirected_to = content_from_source(url)
    
    return nil if url_redirected_to == nil
    
    content_from_headless_browser = content_from_headless_browser(url_redirected_to)
    
    if content_from_source.nil?
      content_from_source = ""
      return nil if content_from_headless_browser.nil?
    elsif content_from_headless_browser.nil?
      content_from_headless_browser = "" 
    end
    
    content_from_source + "\n" + content_from_headless_browser
  end
  
  def content_from_source(url)
    begin
      content = nil
      url_redirected_to = nil
      
      timeout(20) do
        #allow http to https and https to http redirections
        open(url,
          allow_redirections: :all,
          # hong's own user agent in chrome, you should probably fake the one from IE
          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.122 Safari/537.36"
        ) do |response|
          url_redirected_to = response.base_uri.to_s
          puts "Redirected to #{url_redirected_to}"
        
          content = response.read
        end
      end
      
      # check the content's encoding and force it to utf8, discard the invalid characters in utf-8
      content.force_encoding(Encoding::UTF_8)
      if !content.valid_encoding?
        content.encode!(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '')
      end
    
      rescue Timeout::Error
        puts "open timed out"
      rescue Exception => e
        if e.message.include?("getaddrinfo: nodename nor servname provided, or not known") ||
            e.message.include?("404 Not Found")
          # this means we can't reach the server at all, we should probably pause the company
          #company.paused!
        end
        puts "problem #{e.message}"
        pp e.backtrace
        content = nil
      ensure
        return content, url_redirected_to
    end
  end
  
  # Content from the headless browser
  def content_from_headless_browser(url)
    phantomjs = nil
    if(Rails.env.production?)
      phantomjs = './phantomjs/linux/phantomjs'
    else
      phantomjs = './phantomjs/mac_os/phantomjs'
    end
    phantom_output = %x(#{phantomjs} netlog.js #{url})
    
    if phantom_output.include?("Cannot load the address!")
      return nil
    end
    
    phantom_output
  end
  
  private
  
    def matched_services_in_content(content)
      @matchers.select{|m| m.match?(content)}.map(&:service_id).uniq
    end
  

  class << self
    def create_scrape_job(scrape_job_notes)
      scrape_job = ScrapeJob.find_by_notes(scrape_job_notes)
      
      raise "A scrape_job with that name already exists." if scrape_job
      
      ScrapeJob.create!(notes: scrape_job_notes) 
    end
    
    
    # pass in a percentage, (like 50 for scraping 50%), and a page_number (0 means the first 50%, 1 means the second 50%)
    # def scrape_all(percentage = 100, page_number = 0, scrape_job_notes)
    def scrape_all(processes = 1, page_number = 0, scrape_job_notes = nil, options = {})
      scrape_job = ScrapeJob.find_by_notes(scrape_job_notes)

      count = Company.count
      
      limit = (count*1.0/processes).ceil
      offset = page_number*limit
      
      ScrapeService.do_scraping(scrape_job, limit, offset, options)
    end
    
    def scrape_some(scrape_count, processes = 1, page_number = 0, scrape_job_notes = nil, options = {})
      scrape_job = ScrapeJob.find_by_notes(scrape_job_notes)
      
      company_count = Company.count
      
      scrape_count = company_count if scrape_count > company_count
      
      limit = (scrape_count*1.0/processes).ceil
      offset = page_number*limit
      
      ScrapeService.do_scraping(scrape_job, limit, offset, options)
    end
    
    def scrape_special
      puts "scrape_special"
      
      scrape_job = ScrapeJob.find(15)
      scrape_service = ScrapeService.new(scrape_job: scrape_job)
      
      i = 5392  

      while(i <= 8211)
        sr = ScrapedResult.where(scrape_job_id: 15, company_id: i).first
        if sr.nil?
          puts "COULD NOT FIND. company_id: #{i}"
          c = Company.find(i)
          begin
            puts "scraping company #{c.name}"
            scrape_service.scrape(c)
          rescue
            puts "failed to scrape company #{c.name}, strange huh? #{$!.message}"
            pp $!.backtrace
          end
        else
          puts "Found company_id #{i}"
        end
        i += 1
      end 
    end
    
    def do_scraping(scrape_job, limit, offset, options = {})
      scrape_service = ScrapeService.new(scrape_job: scrape_job)
      Company.limit(limit).offset(offset).each do |c|
        begin
          puts "scraping company #{c.name}"
          scrape_service.scrape(c, options)
        rescue
          puts "failed to scrape company #{c.name}, strange huh? #{$!.message}"
          pp $!.backtrace
        end
      end
    end

    def scrape(company, options = {})
      ScrapeService.new.scrape(company, options)
    end
    
    # Scrape a single URL and don't save the results to the DB
    # @author Jason Lew
    def scrape_without_save(url)
      regex_http = /^http[s]*:\/\//

      #strip http
      if url.match(regex_http)
        url.gsub!(regex_http, "")
      end
      
      regex_www = /^www./
      #strip www
      if url.match(regex_www)
        url.gsub!(regex_www, "")
      end
      
      url = "http://" + url
      
      puts "url: #{url}"
      
      service_names = ScrapeService.new.scrape_without_save(url)
      puts "Services:"
      pp service_names
      puts "Number of services: #{service_names.count}"
      service_names
    end
    
  end


  
end
