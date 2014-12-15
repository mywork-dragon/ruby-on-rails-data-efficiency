require 'csv'

class GoChimeSilverpopJob

  # def initialize(options = {})
  #
  # end

  def run(file_path)
    
    CSV.open(file_path, "w+") do |csv|
      
      # csv << ["Company", "Contact", "Title"]
      csv << ["Company"]
      
      installations = Installation.where(scrape_job_id: 34, service_id: 141)
      
      installations.each do |i|
        company_name = i.company.name
        csv << [company_name]
      end
      
    end
      
  end
  
  
  
  class << self
  
    def run(file_path)
      self.new.run(file_path)
    end
  
  end
end

