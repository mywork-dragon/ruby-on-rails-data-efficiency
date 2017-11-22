class Lead < ActiveRecord::Base
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
    lead.lead_data = data
    lead.save

    unless Rails.env.development?
      EmailWorker.perform_async(:contact_us, data)
      SalesforceWorker.perform_async(:add_lead, data)
    end

    lead
  end
end
