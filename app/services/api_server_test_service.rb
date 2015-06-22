class ApiServerTestService
  
  class << self
    
    def get(dev: false)
      
      if dev
        url = 'http://api.lvh.me:3000/ios_apps/547702041'
        headers = nil
      else
        # url = 'http://api.mightysignal.com/ios_apps/547702041'
        url = 'http://api.mightysignal.com/companies?website=dropbox.com'
        headers = {'MightySignal-API-Key' => 'IlKqRg54kBfmDOO_V29R7w'}
      end
      
      response = HTTParty.get(url, headers: headers)
      response.body
    end
    
    def run(n = 1000)
      n.times do |n|
        puts "Request ##{n}"
        puts get
        puts "\n" 
      end
    end
    
  end
  
end