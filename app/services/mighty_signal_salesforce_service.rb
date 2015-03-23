class MightySignalSalesforceService
  
  include SalesforceService

  def initialize(options={})
    super(options)
  end

  def client
    return @client if @client
    
    @client = Restforce.new :username => 'jasonlew@mightysignal.com',
      :password       => 'asfklnSSLFKN1248LSKFN28asfknasf',
      :security_token => '5y94XAXwanKAlk5NKSdk6OuE2',
      :client_id      => '3MVG9fMtCkV6eLhcIlf3UM3DhI0qHjleFYx1eiGwILdwEf8djU26Vnqjd3mu1Kxs0Z258R99eC0sfRJHG548g',
      :client_secret  => '6384884061761347258'
  end
  
  def hydrate_lead(options)
    hydrate_object(:lead, options)
  end
  
  def hydrate_opp(options)
    hydrate_object(:opp, options)
  end
  
  def hydrate_object(object_type, options={})
    id = options[:id]
    email = options[:email]
    
    if email.blank?
      puts "no email"
      return
    end
  
    name = email.split("@").last
    website = "http://" + name

    return if (website =~ URI::regexp).nil?

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
  
    if service_ids.blank?
      puts "no services found"
      return
    end
  
    found_service_names = []
    service_ids.each do |service_id|
      found_service_names << Service.find(service_id).name
    end
  
    puts "found_service_names: #{found_service_names}"
    
    found_service_names_s = found_service_names.sort_by{|word| word.downcase}.join("\n")

    object_name = nil
    if(object_type == :lead)
      object_name = "Lead"
    elsif(object_type == :opp)
      object_name = "Opportunity"
    end
  
    api_hash = {MightySignal_Signals__c: found_service_names_s, MightySignal_Signal_Count__c: found_service_names.count.to_s}
  
    object_params = {Id: id, MightySignal_Last_Updated__c: current_date_time_sf_format}.merge(api_hash)
    client.update!(object_name, object_params)
  
  end
  
  def hydrate_all_leads
    all_leads.each do |lead|
      id = lead.Id
      email = lead.Email
      
      hydrate_lead(id: id, email: email)
    end
  end
  
  def all_leads
    client.query("select Id, Email from Lead")
  end

  def create_lead(options={})
    first_name = options[:first_name]
    last_name = options[:last_name]
    company = options[:company]
    email = options[:email]
    phone = options[:phone]
    message = options[:message]
    crm = options[:crm]
    lead_source = options[:lead_source]

    client.create!('Lead', 'FirstName' => first_name, 'LastName' => last_name, 'Company' => company, 'Email' => email, 'Phone' => phone, 'Message__c' => message, 'CRM__C' => crm, 'LeadSource' => lead_source)
  end
  

  class << self
    
    def create_lead(options={})
      self.new.create_lead(options)
    end
    
    def hydrate_lead(options={})      
      self.new.hydrate_lead(options)
    end
    
    def hydrate_all_leads
      self.new.hydrate_all_leads
    end
    
    def hydrate_opp(options={})      
      self.new.hydrate_opp(options)
    end
  
  end
  
end
