require 'nokogiri'
require 'open-uri'
require 'csv'

class AlexaService
  
  def run(csv_path)
    
    CSV.foreach(csv_path) do |row|
      
      # use row here...
      name = row[1]
      url = "http://" + name
      
      company = Company.find_by_name(name)

      if company.nil?
        created = Company.create(name: name, website: url, status: :active)

        if created
          puts "Added #{name} (#{url} to DB)"
        else
          puts "Error adding #{name} (#{url}) to DB"
        end
      end
    end
    
    puts "DONE!"
    
  end

  
  class << self
  
    def run(csv_path)
      AlexaService.new.run(csv_path)
    end

  end
  
end