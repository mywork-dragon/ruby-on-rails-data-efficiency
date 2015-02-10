require 'csv'

class ApptentiveForeSeeJob

  def run(directory_path)
    
    srs = ScrapedResult.includes(:installations).where(scrape_job_id: 45, installations: {service_id: 226})

    results = []
    
    srs.each do |sr|
      company_name = sr.company.name
      result = {}
      
      result[:company] = company_name
      
      ranks = PageRankr.ranks(company_name)
      result[:alexa] = ranks[:alexa_global]
      
      results << result
      
      puts result
    end
      
    results.sort_by!{|result| result[:alexa]}
      
    filename = "ForeSee.csv"
    
    CSV.open(directory_path + '/' + filename, "w+") do |csv|
      csv << ['Company', 'Alexa Ranking']
      
      results.each do |result|
        line = [result[:company], result[:alexa]]
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