class BizibleSalesforceService

  def initialize(options={})
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

  def client
    client = Restforce.new :username => 'jason@mightysignal.com',
      :password       => 'knKnsjnsansaf23764KSJANFssas',
      :security_token => 'vZyFBHo9FHpqRWjDUhsIrjzdM',
      :client_id      => '3MVG9fMtCkV6eLhfvfGZ559QaTiFUS_ZTpnvTn5pfL9_NAInaNgoW0AcvlslIJ1Xd6tOX7JfkJoo6bB55flRl',
      :client_secret  => '3173051852013251576'
  end

  def hydrate_lead(options={})
    id = options[:id]
    email = options[:email]
    website = options[:website]

    url = UrlService.url_with_http_only(website)

    company = Company.find_by_website(url)

    if company.nil?
      created = Company.create(name: name, website: url, status: :active)

      if created
        puts "Added #{name} (#{company_url_with_http} to DB)"
      else
        puts "Error adding #{name} (#{company_url_with_http}) to DB"
      end

    else
      puts "company already in DB"
    end

    services = ScrapeService.scrape(company)

    salesforce_api_name_service_name_hash = salesforce_api_name_service_name_hash(service)

    salesforce_api_name_service_name_hash.each do |api_name, service_name|

    end
  end

  def salesforce_api_name_service_name_hash(services)

    ret = Hash.new

    @services_hash.each do |api_name, service_names|

      found_service = false
      service_names.each do |service_name|
        #puts "service_name: #{service_name}"
        #service = Service.find_by_name(service_name_in_db(service_name))
        puts "service: #{service.name}"

        #i = Installation.where(company: c, scrape_job_id: 15, service: service).first
        service_on_page = #service in services


        #puts "company: #{c.name}, service: #{service.name}"
        #i = Installation.where(company: c, service: service).first

        #puts "installation: #{i}\n\n"

        if service_on_page
          puts "found service #{service_name} for company #{c.name}"
          if !found_service
            found_service = true
            ret[api_name] = service_name
          else
            #puts "adding #{service_name} to others"
            others << service_name
          end
        end
      end

      if others.count > 0 && api_name == "Other"  #TODO: change


        all_others = nil
        if ret["Other"].nil?
          all_others = others
        else
          all_others = ret["Other"] + others
        end

        # puts "others: #{others}"
        # puts "all_others: #{all_others}"
        # puts "col to delete index: #{csv_line.count - 1}"
        # puts "col to delete: #{csv_line[csv_line.count - 1]}"

        ret['Other'] = nil if found_service

        ret['Others'] << all_others.join(", ")

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


  end

end
