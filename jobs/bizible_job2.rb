require 'csv'

class BizibleJob2 < BizibleJob1

  def create_csv(file_path)
    
    CSV.open(file_path, "w+") do |csv|
      
      csv << ["Company Name"] + @services_hash.keys
      
      #10 processes => 884 at a time
       
      
      File.readlines(Rails.root + "db/bizible/bizible_job2_edu_companies.txt").each_with_index do |l, i|
        company_url = l.strip
        
        puts "Company #{i}: #{l}"
        
        #break if i == 200
        
        company_name = UrlManipulator.url_with_base_only(company_url)
        c = Company.find_by_name(company_name)
        
        csv_line = [company_name]
        others = []
        
        @services_hash.each do |category, service_names|
          
          puts "service_names: #{service_names}"
          
          found_service = false
          service_names.each do |service_name|
            #puts "service_name: #{service_name}"
            service = Service.find_by_name(service_name_in_db(service_name))
            #puts "service: #{service.name}"
            i = Installation.where(company: c, scrape_job_id: 49, service: service).first
            #puts "company: #{c.name}, service: #{service.name}"
            #i = Installation.where(company: c, service: service).first
            
            puts "installation: #{i}\n\n"
            
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
            
            puts "others: #{others}"
            puts "all_others: #{all_others}"
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
      self.new.create_csv(file_path)
    end

    def scrape(processes = 1, page_number = 0, scrape_job_notes = nil, options = {})
      scrape_job = ScrapeJob.find_by_notes(scrape_job_notes)
    
      at_a_time = 16
  
      company_range = []
      10.times do |n|
        company_range[n] = ((n*at_a_time)..(n*at_a_time + at_a_time - 1))
      end
    
      self.do_scraping(scrape_job, company_range[page_number], options)
    end
    
    def do_scraping(scrape_job, range, options = {})
      scrape_service = ScrapeService.new(scrape_job: scrape_job)
      
      File.readlines(Rails.root + "db/bizible/bizible_job2_linkedin_2nd_degree.txt")[range].each_with_index do |l, i|
        company_name = l.strip!
        
        name = UrlManipulator.url_with_base_only(company_name)
        website = UrlManipulator.url_with_http_only(company_name)
        
        company = Company.find_by_name(name)

        if company.nil?
          company = Company.create(name: name, website: website, status: :active)

          if company
            puts "Added #{name} (#{website} to DB)"
          else
            puts "Error adding #{name} (#{website}) to DB"
            next
          end

        else
          puts "company already in DB"
        end
        
        begin
          puts "scraping company #{company.name}"
          scrape_service.scrape(company, options)
        rescue
          puts "failed to scrape company #{company.name}, strange huh? #{$!.message}"
          pp $!.backtrace
        end
      end
      
    end
  
  end

end

