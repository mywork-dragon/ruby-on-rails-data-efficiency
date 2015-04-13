class AddWebsitesFromCompaniesService
  
  class << self
    
    def run_fortune_1000
      cs = Company.where.not(fortune_1000_rank: nil)
    
      cs.each do |c|
        w = Website.find_or_create_by(url: c.website)
      
        w.company = c
        w.save
      
      end
    
    end
  
    def run_rest
      Company.find_each.with_index do |c, index|
        li "Company #{index}" if index%10000 == 0
        AddWebsitesFromCompaniesServiceWorker.perform_async(c.id)
      end
    end
  end
  

  
end