class ApiServerTestService
  
  class << self
    
    def get
      response = HTTParty.get('http://api.mightysignal.com/ios_apps/547702041', headers: {'MightySignal-API-Key' => 'IlKqRg54kBfmDOO_V29R7w'})
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