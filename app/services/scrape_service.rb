require 'open-uri'
class ScrapeService

  def initialize(options = {})
    @matchers = Matcher.all
    @services = Service.all
    
    @scrape_job = options[:scrape_job]
  end

  def scrape(company)
    website = company.website

    content = content_from_source_and_headless_browser(website)
    
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
    
  end
  
  # Scrape a single URL and don't save the results to the DB
  # @author Jason Lew
  def scrape_test(url)
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
    
    content = content_from_source + "\n" + content_from_headless_browser
    
    #content.scrub
  end
  
  def content_from_source(url)
    begin
      content = nil
      url_redirected_to = nil
      
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
      
      
      # check the content's encoding and force it to utf8, discard the invalid characters in utf-8
      content.force_encoding(Encoding::UTF_8)
      if !content.valid_encoding?
        content.encode!(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '')
      end
    
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
    # pass in a percentage, (like 50 for scraping 50%), and a page_number (0 means the first 50%, 1 means the second 50%)
    def scrape_all(percentage = 100, page_number = 0, scrape_job_notes)
      scrape_job = ScrapeJob.find_by_notes(scrape_job_notes)
      scrape_job = ScrapeJob.create!(notes: scrape_job_notes) if scrape_job.nil?
      
      count = Company.active.count
      start_num = (count * percentage * page_number * 1.0 / 100).ceil
      end_num = (count * percentage * (page_number + 1) * 1.0 / 100).floor
      scrape_service = ScrapeService.new(scrape_job: scrape_job)
      #Company.active.limit(end_num - start_num + 1).offset(start_num).each do |c|
      Company.limit(end_num - start_num + 1).offset(start_num).each do |c|
        begin
          puts "scraping company #{c.name}"
          scrape_service.scrape(c)
        rescue
          puts "failed to scrape company #{c.name}, strange huh? #{$!.message}"
          pp $!.backtrace
        end
      end
    end
    
    def scrape_special(options)
      scrape_job = ScrapeJob.find(15)
      company_ids = [5392, 5393, 5394, 5395, 5396, 5397, 5398, 5399, 5400, 5401, 5402, 5403, 5404, 5405, 5406, 5407, 5408, 5409, 5410, 5411, 5412, 5413, 5414, 5415, 5416, 5417, 5418, 5419, 5420, 5421, 5422, 5423, 5424, 5425, 5426, 5427, 5428, 5429, 5430, 5431, 5432, 5433, 5434, 5435, 5436, 5437, 5438, 5439, 5440, 5441, 5442, 5443, 5444, 5445, 5446, 5447, 5448, 5449, 5450, 5451, 5452, 5453, 5454, 5455, 5456, 5457, 5458, 5459, 5460, 5461, 5462, 5463, 5464, 5465, 5466, 5467, 5468, 5469, 5470, 5471, 5472, 5473, 5474, 5475, 5476, 5477, 5478, 5479, 5480, 5481, 5482, 5483, 5484, 5485, 5486, 5487, 5488, 5489, 5490, 5491, 5492, 5493, 5494, 5495, 5496, 5497, 5498, 5499, 5500, 5501, 5502, 5503, 5504, 5505, 5506, 5507, 5508, 5509, 5510, 5511, 5512, 5513, 5514, 5515, 5516, 5517, 5518, 5519, 5520, 5521, 5522, 5523, 5524, 5525, 5526, 5527, 5528, 5529, 5530, 5531, 5532, 5533, 5534, 5535, 5536, 5537, 5538, 5539, 5540, 5541, 5542, 5543, 5544, 5545, 5546, 5547, 5548, 5549, 5550, 5551, 5552, 5553, 5554, 5555, 5556, 5557, 5558, 5559, 5560, 5561, 5562, 5563, 5564, 5565, 5566, 5567, 5568, 5569, 5570, 5571, 5572, 5573, 5574, 5575, 5576, 5577, 5578, 5579, 5580, 5581, 5582, 5583, 5584, 5585, 5586, 5587, 5588, 5589, 5590, 5591, 5592, 5593, 5594, 5595, 5596, 5597, 5598, 5599, 5600, 5601, 5602, 5603, 5604, 5605, 5606, 5607, 5608, 5609, 5610, 5611, 5612, 5613, 5614, 5615, 5616, 5617, 5618, 5619, 5620, 5621, 5622, 5623, 5624, 5625, 5626, 5627, 5628, 5629, 5630, 5631, 5632, 5633, 5634, 5635, 5636, 5637, 5638, 5639, 5640, 5641, 5642, 5643, 5644, 5645, 5646, 5647, 5648, 5649, 5650, 5651, 5652, 5653, 5654, 5655, 5656, 5657, 5658, 5659, 5660, 5661, 5662, 5663, 5664, 5665, 5666, 5667, 5668, 5669, 5670, 5671, 5672, 5673, 5674, 5675, 5676, 5677, 5678, 5679, 5680, 5681, 5682, 5683, 5684, 5685, 5686, 5687, 5688, 5689, 5690, 5691, 5692, 5693, 5694, 5695, 5696, 5697, 5698, 5699, 5700, 5701, 5702, 5703, 5704, 5705, 5706, 5707, 5708, 5709, 5710, 5711, 5712, 5713, 5714, 5715, 8166, 8167, 8168, 8169, 8170, 8171, 8172, 8173, 8174, 8175, 8176, 8177, 8178, 8179, 8180, 8181, 8182, 8183, 8184, 8185, 8186, 8187, 8188, 8189, 8190, 8191, 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8203, 8204, 8205, 8206, 8207, 8208, 8209, 8210, 8211]
      
      scrape_service = ScrapeService.new(scrape_job: scrape_job)
      
      company_ids.each do |company_id|
        c = Company.find(company_id)
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
      service_names = ScrapeService.new.scrape_test(url)
      puts "Services:"
      pp service_names
      puts "Number of services: #{service_names.count}"
      service_names
    end
  end

end
