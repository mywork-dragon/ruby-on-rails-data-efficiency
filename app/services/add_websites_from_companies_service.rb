class AddWebsitesFromCompanies
  
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
        li "Company ##{c}" if index%10000 == 0
        self.delay.run_rest_add(c.id)
      end
    end
    
    def run_rest_add(company_id)
      c = Company.find(company_id)
      w = Website.find_or_create_by(url: c.website)
    end
    
  end
  

  
end