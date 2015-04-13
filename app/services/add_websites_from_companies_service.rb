class AddWebsitesFromCompanies
  
  def run_fortune_1000
    cs = Company.where.not(fortune_1000_rank: nil)
    
    cs.each do |c|
      w = Website.find_or_create_by(url: c.website)
      
      w.company = c
      w.save
      
    end
    
  end
  
end