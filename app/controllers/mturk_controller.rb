class MturkController < ApplicationController

  def gochime
    installations = Installation.where(scrape_job_id: 43, service_id: 141).limit(10)
    
    @company_names = []
    
    installations.each do |i|
      company_name = i.company.name
      
      @company_names << company_name
      
    end
  end

end
