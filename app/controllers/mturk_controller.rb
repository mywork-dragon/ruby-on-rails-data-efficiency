class MturkController < ApplicationController

  def gochime
    installations = Installation.where(scrape_job_id: 43, service_id: 141)
    
    @companies = []
    
    installations.each do |i|
      company_name = i.company.name
      
      @companies << company_name
      
    end
  end

end
