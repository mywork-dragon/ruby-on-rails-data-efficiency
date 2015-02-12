require 'csv'

class ApptentiveForeSeeJob

  def run(directory_path)
    
    srs = ScrapedResult.includes(:installations).where(scrape_job_id: 45, installations: {service_id: 226})
    
    filename = "ForeSee.csv"
    
    CSV.open(directory_path + '/' + filename, "w+") do |csv|
      csv << ['Company', 'Alexa Ranking']
      
      srs.each do |sr|
        company = sr.company.name
        alexa = PageRankr.ranks(company, :alexa_global)
        
        line = [company, alexa]
        
        csv << line
      
        puts line
      end
    end
    
    
    
  end

  class << self

    def run(directory_path)
      self.new.run(directory_path)
    end

  end

end