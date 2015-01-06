class TriggermailDemoSalesforceService

  include SalesforceService

  def initialize(options={})
    super(options)
    
    @services_hash = Hash.new

    @services_hash['Marketing Automation'] = ['Marketo', 'Pardot', 'Hubspot', 'Act-On Beacon', 'Eloqua', 'Silverpop']

    @services_hash['Tag Management'] = ['Tealium', 'Ensighten', 'Adobe Tag Container', 'Signal.co', 'Google Tag Manager']

                                
    @api_hash = {}
    @api_hash['Marketing Automation'] = {lead: 'Marketing_Automation__c', opp: "Marketing_Automation__c"}
    @api_hash['Tag Management'] = {lead: 'Tag_Manager__c', opp: 'Tag_Manager__c'}
    
    sf_object_type = options[:object_type]
    
    @lead_services_hash = Hash.new
    @opp_services_hash = Hash.new
    
    @api_hash.each do |key, value|
      @lead_services_hash[value[:lead]] = @services_hash[key]
      @opp_services_hash[value[:opp]] = @services_hash[key]
    end                            
    
    puts "@lead_services_hash: #{@lead_services_hash}"
  end

  def client
    return @client if @client
    
    @client = Restforce.new :username => 'jason_triggermail@mightysignal.com',
      :password       => 'alskfnclkansf12422',
      :security_token => 'myKlAxydIqstRnXJlCwoU46c',
      :client_id      => '3MVG9fMtCkV6eLheWeuPjSg0j18ozUv5a1UaTfM9Fm5zoj3xJuPtrfum0nWZlK6LE62.jQLrR6Y_fnxJBS.7i',
      :client_secret  => '8577635590104229957'
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

    ret = {"Marketing_Automation__c" => [], "Tag_Manager__c" => [], "Other_Signals__c" => []}

    not_other = []

    services_hash = nil
    
    if(object_type == :lead)
      services_hash = @lead_services_hash
    elsif(object_type == :opp)
      services_hash = @opp_services_hash
    end
    
    services_hash.each do |api_name, service_names|

      service_names.each do |service_name|
        if found_service_names.include?(service_name)
          ret[api_name] << service_name
          not_other << service_name
        end
      end

    end
    
    ret["Other_Signals__c"] << found_service_names - not_other
    
    ret.each do |api_name, service_names|
      ret[api_name] = service_names.join(", ")
    end
    
    ret

  end

  class << self

    def hydrate_lead(options={})      
      self.new.hydrate_lead(options)
    end
    
    def hydrate_opp(options={})      
      self.new.hydrate_opp(options)
    end


  end

end
