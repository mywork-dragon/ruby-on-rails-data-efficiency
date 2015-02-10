require 'csv'

class ApptentiveForeSeeJob

  def run(directory_path)
    
    srs = ScrapedResult.includes(:installations).where(scrape_job_id: 45, installations: {service_id: 226})

      
    filename = "ForeSee.csv"
    
    CSV.open(directory_path + '/' + filename, "w+") do |csv|
      srs.each do |sr|
        company_name = sr.company.name
        csv << [company_name]
        puts company_name
      end
    end
    
  end

  class << self

    def run(directory_path)
      self.new.run(directory_path)
    end

  end

end