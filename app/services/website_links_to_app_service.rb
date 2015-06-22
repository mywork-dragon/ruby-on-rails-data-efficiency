class WebsiteLinksToAppService
  
  BYPASS = false

=begin
  def links?(app_name:, app_identifier:, domain:, platform:)
    @domain = domain
    
    if platform == :ios
      app_term = ['iPhone', 'iOS', 'iPad'].shuffle.join(' OR ') + ' app'
      match_term = "id#{app_identifier}"
    elsif platform == :android
      app_term = 'Android app'
      match_term = app_identifier
    end

    query = CGI::escape("site:#{domain} #{app_name} #{app_term}")
    #puts "query: #{query}"
  	google_url = "http://www.google.com/search?q=#{query}"
    #puts "url: #{google_url}"
    
    begin
      results_html = Tor.get(google_url, bypass: BYPASS)
      #puts "results_html: #{results_html}"
      #File.open('/Users/jason/Desktop/google.html', 'w:ASCII-8BIT') { |file| file.write(results_html)}
      results = Nokogiri::HTML(results_html)

    	res = res(results)

      #puts "res: #{res}"
      
      first_result = res.first
      first_result_url = "http://#{first_result}"
      first_res_html = Tor.get(first_result_url, bypass: BYPASS)
      
      #puts first_res_html
    
      return true if first_res_html.include?(match_term)
    rescue Exception => e
      le "Exception: #{e.message}"
      false
    end
    
  	false

  end
=end

  def res(results_html)
    results = results_html.search('cite').map do |cite|
      url = cite.inner_text
      url if url.include?(@domain)
    end
    results.reject{ |r| r.blank? }
  end
  
  class << self
    
    def links?(app_name: "IMDb Movies & TV", app_identifier: 342792525, domain: "imdb.com", platform: :ios)
      self.new.links?(app_name: app_name, app_identifier: app_identifier, domain: domain, platform: platform)
    end
    
  end

end