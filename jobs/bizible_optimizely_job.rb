require 'csv'

class BizibleOptimizelyJob

  def run(directory_path)
    scrape_job_id = 43
    
    optimizely_id = 513
    marketo_id = 138
    pardot_id = 204
    
    srs_o_m = ScrapedResult.includes(:installations).where(scrape_job_id: scrape_job_id, installations: {service_id: optimizely_id}) & ScrapedResult.includes(:installations).where(scrape_job_id: scrape_job_id, installations: {service_id: marketo_id})
    srs_o_p = ScrapedResult.includes(:installations).where(scrape_job_id: scrape_job_id, installations: {service_id: optimizely_id}) & ScrapedResult.includes(:installations).where(scrape_job_id: scrape_job_id, installations: {service_id: pardot_id})
    
    [srs_o_m, srs_o_p].each do |srs|
      
      filename = ""
      if srs == srs_o_m
        filename = "optimizely_and_marketo.csv"
      elsif srs = srs_o_p
        filename = "optimizely_and_pardot.csv"
      end
      
      CSV.open(directory_path + '/' + filename, "w+") do |csv|
        srs.each do |sr|
          company_name = sr.company.name
          csv << [company_name]
          puts company_name
        end
      end
    end
    
    
    
  end

  class << self

    def run(directory_path)
      BizibleOptimizelyJob.new.run(directory_path)
    end

  end

end