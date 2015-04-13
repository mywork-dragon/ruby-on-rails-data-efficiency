class AddWebsitesFromCompanies
  
  def run_fortune_1000
    cs = Company.where.not(fortune_1000_rank: nil)
    
    cs.each do |c|
      w = Website.new(url: url)
      success = w.save
      
      if success
        w.company = c
        w.save
      end
      
    end
    
  end
  
end