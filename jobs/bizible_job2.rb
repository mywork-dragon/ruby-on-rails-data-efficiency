require 'csv'

class BizibleJob2 < BizibleJob1

  def run(file_path)
    
    CSV.open(file_path, "w+") do |csv|
      
      csv << ["Company Name"] + @services_hash.keys
      
      File.readlines(Rails.root + "db/bizible/bizible_job2_companies.txt").each_with_index do |l, i|
        company_name = l.strip!

        puts "Company: #{company_name}"
        
        next
        
        #break if i == 200
        
        #for each line
        c = Company.find_by_name(company_name)
        
        csv_line = [company_name]
        others = []
        
        @services_hash.each do |category, service_names|
          
          #puts "service_names: #{service_names}"
          
          found_service = false
          service_names.each do |service_name|
            #puts "service_name: #{service_name}"
            service = Service.find_by_name(service_name_in_db(service_name))
            #puts "service: #{service.name}"
            i = Installation.where(company: c, scrape_job_id: 15, service: service).first
            #puts "company: #{c.name}, service: #{service.name}"
            #i = Installation.where(company: c, service: service).first
            
            #puts "installation: #{i}\n\n"
            
            if i
              #puts "found service #{service_name} for company #{c.name}"
              if !found_service
                found_service = true
                csv_line << service_name
              else
                #puts "adding #{service_name} to others"
                others << service_name
              end
            end
          end
          
          if others.count > 0 && category == "Other"
            
            
            all_others = nil
            if csv_line.last.blank?
              all_others = others
            else
              all_others = [csv_line.last] + others
            end
            
            # puts "others: #{others}"
            # puts "all_others: #{all_others}"
            # puts "col to delete index: #{csv_line.count - 1}"
            # puts "col to delete: #{csv_line[csv_line.count - 1]}"
            
            csv_line.delete_at(csv_line.count - 1) if found_service
            
            csv_line << all_others.join(", ")
            
            found_service = true
          end
          
          csv_line << "" if !found_service
        end
        
        csv << csv_line
      end
      
    end
      
  end
  
  
  class << self
  
    def run(file_path)
      self.new.run(file_path)
    end
  
  end
end

