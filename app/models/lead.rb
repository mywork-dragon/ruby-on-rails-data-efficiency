class Lead < ActiveRecord::Base
  visitable
  
  has_many :visits, class_name: "Ahoy::Visit"
  has_many :events, class_name: "Ahoy::Event"
  
  serialize :lead_data, Hash

  def self.create_lead(data)
    data = data.with_indifferent_access
    lead = Lead.new(email: data[:email])
    lead.first_name = data[:first_name]
    lead.last_name = data[:last_name]
    lead.company = data[:company]
    lead.phone = data[:phone]
    lead.crm = data[:crm]
    lead.sdk = data[:sdk]
    lead.message = data[:message]
    lead.lead_source = data[:lead_source]
    lead.lead_source ||= data[:ad_source] # need to clean up lead_source vs ad_source
    lead.utm_source = data[:utm_source]
    lead.utm_medium = data[:utm_medium]
    lead.utm_campaign = data[:utm_campaign]
    lead.referrer = data[:referrer]
    lead.referring_domain = data[:referring_domain]
    lead.lead_data = data
    lead.save

    # unless Rails.env.development?

      if (data[:first_name].present? || data[:last_name].present?) && (data[:email].present? || data[:phone].present?)
        puts "data: #{data}"
        EmailWorker.perform_async(:contact_us, data)
      end
      
      
      SalesforceWorker.perform_async(:add_lead, data)
    # end

    lead
  end
end
