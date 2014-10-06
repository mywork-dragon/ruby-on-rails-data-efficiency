require 'csv'

class BizibleJob1

  def initialize(options = {})
    
    @services_hash = Hash.new
    
    @services_hash['Marketing Automation'] = ['Marketo', 'Pardot', 'Hubspot', 'Act On', 'Eloqua', 'Silverpop']
    
    @services_hash['Live Chat'] = ['SnapEngage', 'Olark', 'Bold Chat', 'Live Agent', 'Zopim', 'LivePerson', 'LiveChat']

    @services_hash['Tag Management'] = ['Tealium', 'Ensighten', 'Adobe', 'Signal.co', 'Google Tag Manager']
    
    @services_hash['Conversion Tracking'] = ['AdWords']
    
    @services_hash['Analytics'] = ['Omniture', 'Sitecatalyst', 'Kissmetrics']
    
    @services_hash['A/B Testing'] = ['VisualWebOptimizer', 'Optimizely', 'Adobe Test&Target']
    
    @services_hash['Bid Management'] = ['Marin', 'Kenshoo', 'Acquisio']
    
    @services_hash['Call Tracking'] = ['Mongoose', 'Ifbyphone']
    
    @services_hash['Other'] = ['Facebook conversion', 'AdRoll conversion', 'DemandBase', 'Bizo',
                                'Doubleclick', 'Twitter conversion tracking', 'Lead Lander',
                                'Radiumone', 'captora', 'DaddyAnalytics', 'BlueKai',
                                'LinkedIn Conversion Tracking']
                                
    @service_name_in_db_hash = {
      'Act On' => 'Act-On Beacon',
      'Live Agent' => 'Salesforce Live Agent',
      'Bold Chat' => "Boldchat",
      'Adobe' => 'Adobe Tag Container',
      'AdWords' => 'Google AdWords Conversion',
      'Omniture' => 'Omniture (Adobe Analytics)',
      'Kissmetrics' => 'KissMetrics',
      'VisualWebOptimizer' => 'Visual Website Optimizer',
      'Adobe Test&Target' => 'Adobe Test & Target',
      'Marin' => 'Marin Search Marketer',
      'Mongoose' => 'Mongoose Metrics',
      'Facebook conversion' => 'Facebook Conversion Tracking',
      'AdRoll conversion' => 'AdRoll',
      'DemandBase' => 'Demandbase',
      'Doubleclick' => 'DoubleClick',
      'Twitter conversion tracking' => 'Twitter Advertising',
      'Lead Lander' => 'LeadLander',
      'Radiumone' => 'RadiumOne',
      'captora' => 'Captora',
      'DaddyAnalytics' => 'DaddyAnalytics',
      'BlueKai' => 'BlueKai',
      'LinkedIn Conversion Tracking' => 'LinkedIn Ads'
    }
  end

  def run(file_path)
    #puts "run"
    
    CSV.open(file_path, "w+") do |csv|
      
      csv << ["Company Name"] + @services_hash.keys
      
      File.readlines(Rails.root + "db/bizible/companies.txt").each_with_index do |l, i|
        company_name = l.strip!
        
      #dummy_company_names = ["optimizely.com", "bizo.com", "bluenile.com", "delta.com"]
      # dummy_company_names = ["accessdevelopment.com", "accenture.com", "acumensolutions.com"]
      # dummy_company_names.each_with_index do |company_name, i|
        puts "Company #{i}"
        
        break if i == 200
        
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
  
  
  
  def service_name_in_db(name)
    name_in_db = @service_name_in_db_hash[name]
    
    return name if name_in_db.nil?
    
    #puts "name_in_db: #{name_in_db}"
    
    name_in_db
  end
  
  class << self
  
    def run(file_path)
      BizibleJob1.new.run(file_path)
    end
  
  end
end

