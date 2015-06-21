class ApiServerTestService
  
  class << self
    
    def get(dev: false)
      
      url = dev ? 'http://api.mightysignal.com/ios_apps/547702041' : 'api.lvh.me/ios_apps/547702041'
      
      response = HTTParty.get(url, headers: {'MightySignal-API-Key' => 'IlKqRg54kBfmDOO_V29R7w'})
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