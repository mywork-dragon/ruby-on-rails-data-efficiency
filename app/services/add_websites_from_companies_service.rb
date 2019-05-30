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
      Company.find_in_batches(batch_size: 1000).with_index do |batch, index|
        li "Batch #{index}"
        ids = batch.map{|c| c.id}
    
        AddWebsitesFromCompaniesServiceWorker.perform_async(ids)
      end
    end
  end
  

  
end