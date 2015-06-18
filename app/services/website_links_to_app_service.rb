class WebsiteLinksToAppService
  
  class << self
  
    def links?(app_name: "IMDb Movies & TV", app_id: "342792525", domain: "imdb.com")
      query = CGI::escape("site:#{domain} #{app_name} iPhone OR iOS OR Android app")
      #puts "query: #{query}"
    	google_url = "http://www.google.com/search?q=#{query}"
      #puts "url: #{googleUrl}"
      
      results_html = Tor.get(google_url)
      puts "results_html: #{results_html}"
      results = Nokogiri::HTML(results_html)

    	res = res(results)

      puts "res: #{res}"

      first_res_html = Tor.get(res[0])
      
    	first_res = Nokogiri::HTML(first_res_html)

    	first_res.xpath("//a").each do |a|
    		href = a.xpath("./@href")
    		if href.to_s.include? app_id
    			return true
    		end
    	end

    	false

    end

    def res(results)
      search_results = []
      for res in results.xpath("//li[@class=\"g\"]")
        url = res.xpath("./h3[@class=\"r\"]/a/@href").to_s.split("=")[1].to_s.split("&")[0]
        search_results << url
      end
      search_results
    end



  end
  
end