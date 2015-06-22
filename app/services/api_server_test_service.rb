class ApiServerTestService
  
  class << self
    
    def ios_apps(app_store_id=54770204, dev: false)
      
      if dev
        url = "http://api.lvh.me:3000/ios_apps?appStoreId=#{app_store_id}"
        headers = nil
      else
        url = "http://api.mightysignal.com/ios_apps?appStoreId=#{app_store_id}"
        headers = production_headers
      end
      
      response = HTTParty.get(url, headers: headers)
      response.body
    end
    
    def android_apps(google_play_id='com.instagram.android', dev: false)
      
      if dev
        url = "http://api.lvh.me:3000/android_apps?googlePlayId=#{google_play_id}"
        headers = nil
      else
        url = "http://api.mightysignal.com/ios_apps?googlePlayId=#{google_play_id}"
        headers = production_headers
      end
      
      response = HTTParty.get(url, headers: headers)
      response.body
    end
    
    def ios_apps(website='instagram.com', dev: false)
      
      if dev
        url = "http://api.lvh.me:3000/companies?website=#{website}"
        headers = nil
      else
        url = "http://api.mightysignal.com/companies?website=#{website}"
        headers = production_headers
      end
      
      response = HTTParty.get(url, headers: headers)
      response.body
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