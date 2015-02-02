class BizibleSalesforceService

  include SalesforceService

  def initialize(options={})
    super(options)
    
    @demo = false
    
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
    @api_hash['Analytics'] = {lead: 'Intel_Analytics_Tag__c', opp: "Intel_Analytics_Tag__c"}
    @api_hash['A/B Testing'] = {lead: 'Intel_A_B_Testing__c', opp: "Intel_A_B_Testing__c"}
    @api_hash['Bid Management'] = {lead: 'Intel_Bid_Management__c', opp: 'Intel_Bid_Management__c'}
    @api_hash['Call Tracking'] = {lead: 'Intel_Call_Tracking__c', opp: 'Intel_Call_Tracking__c'}
    @api_hash['Other'] = {lead: 'Intel_Other_Tech__c', opp: "Intel_Other_Tech__c"}
    
    sf_object_type = options[:object_type]
    
    @lead_services_hash = Hash.new
    @opp_services_hash = Hash.new
    
    #puts "@lead_services_hash: #{@lead_services_hash}"
    
    @api_hash.each do |key, value|
      @lead_services_hash[value[:lead]] = @services_hash[key]
      @opp_services_hash[value[:opp]] = @services_hash[key]
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
    
    # @client = Restforce.new :username => 'jason@mightysignal.com',
    #   :password       => 'kajsbkjbPSLFPSkaj22424bb24b',
    #   :security_token => '3GeHCzyOgLrpqlXz0cYduh50',
    #   :client_id      => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',
    #   :client_secret  => '3173051852013251576'
  
    su = OauthUser.find_by_email("aaron@bizible.com")

  @client = Restforce.new :oauth_token => su.oauth_token,
    :refresh_token => su.refresh_token,
    :instance_url  => su.instance_url,
    :client_id     => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',  #need to fix
    :client_secret => '3173051852013251576' #need to fix
  
  end

  def hydrate_lead(options)
    email = options[:email]
    
    name = email.split("@").last
    website = "http://" + name

    return if (website =~ URI::regexp).nil?
    
    hydrate_object(:lead, {id: options[:id], website: website, name: name})
  end
  
  def hydrate_opp(options)
    website = options[:website]
    
    name = UrlManipulator.url_with_base_only(website)
    
    website = UrlManipulator.url_with_http_only(website)
    
    return if (website =~ URI::regexp).nil?
    
    hydrate_object(:opp, {id: options[:id], website: website, name: name})
  end

  def hydrate_object(object_type, options={})
    id = options[:id]
    website = options[:website]
    name = options[:name]
    
    company = Company.find_by_name(name)

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
    
    if @demo
      demo_hash = Hash.new
      
      salesforce_api_name_service_name_hash.each do |key, value|
        demo_hash["MightySignalBiz__" + key] = value
      end
      
      salesforce_api_name_service_name_hash = demo_hash
    end
    
    
    object_params = {Id: id, "MightySignalBiz__MightySignal_Last_Updated__c" => current_date_time_sf_format}.merge(salesforce_api_name_service_name_hash)
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
        #puts "service_name: #{service_name}"
        
        service_name_in_db = @service_name_in_db_hash[service_name]
        service_name_in_db = service_name if service_name_in_db.nil?
        
        #puts "service_name_in_db: #{service_name_in_db}"
        #puts ""
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
  
  def opportunities
    client = self.client
    
    opps = client.query("SELECT Id, Name, CreatedDate, Website__c FROM Opportunity ORDER BY CreatedDate DESC LIMIT 10")
  end

  class << self

    def client
      BizibleSalesforceService.new.client
    end

    def hydrate_lead(options={})      
      BizibleSalesforceService.new.hydrate_lead(options)
    end
    
    def hydrate_opp(options={})      
      BizibleSalesforceService.new.hydrate_opp(options)
    end
    
    def run_test
      client = self.client

      leads = client.query("SELECT Id, Name, LastModifiedDate FROM Lead ORDER BY LastModifiedDate DESC LIMIT 10")
  
      leads.each do |lead|
        puts lead.Name
      end
    
    end
    
    def hydrate_opportunities
      #opps = client.query("SELECT Id, Name, CreatedDate, Website__c FROM Opportunity ORDER BY CreatedDate DESC LIMIT 10")
      opps = client.query("SELECT Id, Name, CreatedDate, Website__c FROM Opportunity ORDER BY CreatedDate DESC")
      
      opps_count = opps.count
      
      opps.each_with_index do |opp, index|
        puts "Company ##{index + 1} of #{opps_count}"
        begin
           BizibleSalesforceService.hydrate_opp(id: opp.Id, website: opp.Website__c, name: opp.name)
    
        rescue Exception => e
          puts "skipping... problem #{e.message}"
          pp e.backtrace
        end
      end
      
    end

  end

end
