class ApiServerTestService
  
  class << self
    
    def ios_apps(app_store_id=530003802, dev: false)
      
      app_store_id = CGI::escape(app_store_id.to_s)
      
      if dev
        url = "http://api.lvh.me:3000/ios_apps?appStoreId=#{app_store_id}"
        headers = nil
      else
        url = "http://api.mightysignal.com/ios_apps?appStoreId=#{app_store_id}"
        headers = production_headers
      end
      
      response = HTTParty.get(url, headers: headers)
      JSON.parse(response.body)
    end
    
    def android_apps(google_play_id='com.instagram.android', dev: false)
      
      google_play_id = CGI::escape(google_play_id)
      
      if dev
        url = "http://api.lvh.me:3000/android_apps?googlePlayId=#{google_play_id}"
        headers = nil
      else
        url = "http://api.mightysignal.com/android_apps?googlePlayId=#{google_play_id}"
        headers = production_headers
      end
      
      response = HTTParty.get(url, headers: headers)
      JSON.parse(response.body)
    end
    
    def companies(website='costco.com ', dev: false)
      
      website = CGI::escape(website)
      
      if dev
        url = "http://api.lvh.me:3000/companies?website=#{website}"
        headers = nil
      else
        url = "http://api.mightysignal.com/companies?website=#{website}"
        headers = production_headers
      end
      
      response = HTTParty.get(url, headers: headers)
      JSON.parse(response.body)
    end
    
    def companies2(website='costco.com ', dev: false)
      
      website = CGI::escape(website)
      
      if dev
        url = "http://api.lvh.me:3000/companies2?website=#{website}"
        headers = nil
      else
        url = "http://api.mightysignal.com/companies2?website=#{website}"
        headers = production_headers
      end
      
      response = HTTParty.get(url, headers: headers)
      JSON.parse(response.body)
    end
    
    
    def production_headers
      {'MightySignal-API-Key' => 'IlKqRg54kBfmDOO_V29R7w'}
    end
    
    def run(n = 1000)
      n.times do |n|
        puts "Request ##{n}"
        puts ios_apps
        puts "\n" 
      end
    end
    
  end
  
end