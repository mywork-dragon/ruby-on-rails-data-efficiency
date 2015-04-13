class AddWebsitesFromCompaniesServiceWorker
  include Sidekiq::Worker

  def perform(company_id)
    c = Company.find(company_id)
    w = Website.find_or_create_by(url: c.website)
  end
  
end