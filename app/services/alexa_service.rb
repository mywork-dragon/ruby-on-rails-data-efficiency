require 'nokogiri'
require 'open-uri'
require 'csv'

class AlexaService
  
  def run(csv_path)
    
    puts "run"
    
    open(csv_path) do |csv|
      csv.each_line do |line|
        
        values = line.split(",")
        
        name = values[1].to_s.strip
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
    end
    
    puts "DONE!"
    
  end

  def test_old(csv_path)
    
    CSV.foreach(csv_path) do |row|
      puts row[0]
    end
    
    puts "DONE!"
    
  end
  
  def test_new(csv_path)
    
    open(csv_path) do |csv|
      csv.each_line do |line|
        values = line.split(",")
        puts values[0]
      end
    end
    
  end
  
  
  class << self
  
    def run(csv_path)
      AlexaService.new.run(csv_path)
    end
    
    def test_old(csv_path)
      AlexaService.new.test_old(csv_path)
    end
    
    def test_new(csv_path)
      AlexaService.new.test_new(csv_path)
    end

  end
  
end