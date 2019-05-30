class AddWebsitesFromCompaniesServiceWorker
  include Sidekiq::Worker

  def perform(company_ids)
    
    company_ids.each do |id|
      c = Company.find(id)
      w = Website.find_or_create_by(url: c.website)
    end

  end
  
end