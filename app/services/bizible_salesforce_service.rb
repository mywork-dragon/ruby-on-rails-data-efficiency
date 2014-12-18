class BizibleSalesforceService

  include SalesforceService

  def initialize(options={})
    super(options)
    
    @services_hash = Hash.new

    @services_hash['Marketing Automation'] = ['Marketo', 'Pardot', 'Hubspot', 'Act On', 'Eloqua', 'Silverpop']

    @services_hash['Live Chat'] = ['SnapEngage', 'Olark', 'Bold Chat', 'Live Agent', 'Zopim', 'LivePerson', 'LiveChat']

    @services_hash['Tag Management'] = ['Tealium', 'Ensighten', 'Adobe', 'Signal.co', 'Google Tag Manager']

    @services_hash['Conversion Tracking'] = ['AdWords']

    @services_hash['Analytics'] = ['Omniture', 'Sitecatalyst', 'Kissmetrics']

    @services_hash['A/B Testing'] = ['VisualWebOptimizer', 'Optimizely', 'Adobe Test&Target']

    @services_hash['Bid Management'] = ['Marin', 'Kenshoo', 'Acquisio']

    @services_hash['Call Tracking'] = ['Mongoose', 'Ifbyphone']

    @services_hash["Other"] = ['Facebook conversion', 'AdRoll conversion', 'DemandBase', 'Bizo',
                                'Doubleclick', 'Twitter conversion tracking', 'Lead Lander',
                                'Radiumone', 'captora', 'DaddyAnalytics', 'BlueKai',
                                'LinkedIn Conversion Tracking']
                                
    @api_hash = {}
    @api_hash['Marketing Automation'] = {lead: 'Intel_Marketing_Automation__c', opp: "Marketing_Automation__c"}
    @api_hash['Live Chat'] = {lead: 'Intel_Live_Chat__c', opp: 'Web_Chat_Software__c'}
    @api_hash['Tag Management'] = {lead: 'Intel_Tag_Manager__c', opp: 'Intel_Tag_Manager__c'}
    @api_hash['Conversion Tracking'] = {lead: 'Intel_Adwords_Conversion_Tag__c', opp: 'Intel_Adwords_Conversion_Tag__c'}
    @api_hash['Analytics'] = {lead: 'Intel_Analytics_Tag__c', opp: ""}
    @api_hash['A/B Testing'] = {lead: 'Intel_A_B_Testing__c', opp: ""}
    @api_hash['Bid Management'] = {lead: 'Intel_Bid_Management__c', opp: 'Intel_Bid_Management__c'}
    @api_hash['Call Tracking'] = {lead: 'Intel_Call_Tracking__c', opp: 'Intel_Call_Tracking__c'}
    @api_hash['Other'] = {lead: 'Intel_Other_Tech__c', opp: "Intel_Other_Tech__c"}
    
    sf_object_type = options[:object_type]
    
    @lead_services_hash = Hash.new
    @opps_services_hash = Hash.new
    
    #puts "@lead_services_hash: #{@lead_services_hash}"
    
    @api_hash.each do |key, value|
      @lead_services_hash[value[:lead]] = @services_hash[key]
      @opps_services_hash[value[:opps]] = @services_hash[key]
    end                            

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

  def client
    return @client if @client
    
    @client = Restforce.new :username => 'jason@mightysignal.com',
      :password       => 'knKnsjnsansaf23764KSJANFssas',
      :security_token => 'vZyFBHo9FHpqRWjDUhsIrjzdM',
      :client_id      => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',
      :client_secret  => '3173051852013251576'
  end

  def hydrate_lead(options)
    email = options[:email]
    
    name = email.split("@").last
    website = "http://" + name

    return if (website =~ URI::regexp).nil?
    
    hydrate_object(:lead, {id: options[:id], website: website, name: name})
  end
  
  def hydrate_opp(options)
    hydrate_object(:opp, options)
  end

  def hydrate_object(object_type, options={})
    id = options[:id]
    website = options[:website]

    company = Company.find_by_website(website)

    if company.nil?
      company = Company.create(name: name, website: website, status: :active)

      if company
        puts "Added #{name} (#{website} to DB)"
      else
        puts "Error adding #{name} (#{website}) to DB"
      end

    else
      puts "company already in DB"
    end

    service_ids = ScrapeService.scrape(company)
    
    found_service_names = []
    service_ids.each do |service_id|
      found_service_names << Service.find(service_id).name
    end
    
    puts "found_service_names: #{found_service_names}"

    salesforce_api_name_service_name_hash = salesforce_api_name_service_name_hash(object_type, found_service_names)
    
    #AdWords is Boolean
    salesforce_api_name_service_name_hash[@api_hash['Conversion Tracking'][object_type]] = "true" if salesforce_api_name_service_name_hash[@api_hash['Conversion Tracking'][object_type]]
    

    object_name = nil
    if(object_type == :lead)
      object_name = "Lead"
    elsif(object_type == :opp)
      object_name = "Opportunity"
    end
    
    
    
    object_params = {Id: id, MightySignal_Last_Updated__c: current_date_time_sf_format}.merge(salesforce_api_name_service_name_hash)
    client.update!(object_name, object_params)
    
  end

  def salesforce_api_name_service_name_hash(object_type, found_service_names)

    ret = Hash.new

    others = [] #others overflow
    
    other_api_name = @api_hash['Other'][object_type]

    services_hash = nil
    
    if(object_type == :lead)
      services_hash = @lead_services_hash
    elsif(object_type == :opp)
      services_hash = @opp_services_hash
    end
    
    services_hash.each do |api_name, service_names|

      found_service = false #for thie api_name
      service_names.each do |service_name|
        puts "service_name: #{service_name}"
        
        service_name_in_db = @service_name_in_db_hash[service_name]
        service_name_in_db = service_name if service_name_in_db.nil?
        
        puts "service_name_in_db: #{service_name_in_db}"
        puts ""
        #service = Service.find_by_name(service_name_in_db(service_name))

        #i = Installation.where(company: c, scrape_job_id: 15, service: service).first
        service_on_page = found_service_names.include?(service_name_in_db)

        #puts "company: #{c.name}, service: #{service.name}"
        #i = Installation.where(company: c, service: service).first

        #puts "installation: #{i}\n\n"

        if service_on_page
          puts "found service #{service_name_in_db}"
          if !found_service
            found_service = true
            ret[api_name] = service_name
          else
            #puts "adding #{service_name} to others"
            others << service_name
          end
        end
      end

      if others.count > 0 && api_name == other_api_name  #TODO: change
        
        all_others = nil  #other overflow plus those categorized as Other
        if ret[other_api_name].nil?
          all_others = others
        else
          all_others = [ret[other_api_name]] + others
        end

        puts "others: #{others}"
        puts "all_others: #{all_others}"
        # puts "col to delete index: #{csv_line.count - 1}"
        # puts "col to delete: #{csv_line[csv_line.count - 1]}"

        ret[other_api_name] = nil if found_service
        
        ret[other_api_name] = "" if ret[other_api_name].nil?

        ret[other_api_name] << all_others.join(", ")

        found_service = true
      end

    end

    ret

  end

  class << self

    def client
      RestforceService.new.client
    end

    def hydrate_lead(options={})      
      BizibleSalesforceService.new.hydrate_lead(options)
    end
    
    def hydrate_opp(options={})      
      BizibleSalesforceService.new.hydrate_opp(options)
    end


  end

end
