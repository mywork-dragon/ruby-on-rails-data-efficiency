# Test the new Tor server
class NewTorService
  
  class << self
    
    def run
      
      IosApp.find_each.with_index do |ios_app, index|
        li "App ##{index}" if index%10000 == 0
        NewTorServiceWorker.perform_async(ios_app.id)
      end
      
    end
    
  end
  
end