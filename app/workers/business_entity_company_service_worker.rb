class BusinessEntityCompanyServiceWorker

  include Sidekiq::Worker
  
  sidekiq_options retry: false
 
  def perform(ids)
    linkedin_validation(ids)
  end

  def linkedin_validation(ids: ["1072422"])
  	ids.each do |id|
      c = Company.find_by_id(id)
      c_name = c.name
      next if PublicSuffix.valid?(c_name) || c_name.nil?

      websites = c.websites.map{|w| Domainator.parse(w.url.downcase)}

      linkedin = linkedin_id(company_name: c_name, websites: websites)

      puts linkedin

      # if linkedin != false
      #   c.linkedin = linkedin
      #   c.save
      # end

    end
  end

  BYPASS = false

  def linkedin_id(company_name:, websites:)
    
    query = CGI::escape("site:linkedin.com/company #{company_name}")
    google_url = "http://www.google.com/search?q=#{query}&num=1"
    
    begin
      results_html = Tor.get(google_url, bypass: BYPASS)
      results = Nokogiri::HTML(results_html)

      res = res(results)
      
      first_result = res.first
      first_result_url = "http://#{first_result}"

      first_res_html = Tor.get(first_result_url, bypass: BYPASS)
    
      id = websites.select{|w| first_res_html.include?(w)}.map{|w| w.gsub('https://www.linkedin.com/company/','')}.first

      return id if id.present?
      
    rescue Exception => e
      le "Exception: #{e.message}"
      false
    end
    
    false

  end

  def res(results_html)
    results = results_html.search('cite').map do |cite|
      url = cite.inner_text.split(' ')[0]
      url if url.include?('linkedin.com')
    end
    results.reject{ |r| r.blank? }
  end


  
end
