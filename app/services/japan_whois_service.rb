class JapanWhoisService

  class << self
    
    def run
      
      JpIosAppSnapshot.find_each.with_index do |ss, index|
        li "App ##{index}" if index%10000 == 0
      
        JapanWhoisServiceWorker.perform(ss.id)
      end
      
    end
    
  end

end