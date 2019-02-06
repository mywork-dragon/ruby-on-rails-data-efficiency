# == Schema Information
#
# Table name: leads
#
#  id               :integer          not null, primary key
#  email            :string(191)
#  first_name       :string(191)
#  last_name        :string(191)
#  company          :string(191)
#  phone            :string(191)
#  crm              :string(191)
#  sdk              :string(191)
#  message          :text(65535)
#  lead_source      :string(191)
#  lead_data        :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  referrer         :text(65535)
#  referring_domain :string(191)
#  utm_source       :string(191)
#  utm_medium       :string(191)
#  utm_campaign     :string(191)
#  landing_page     :string(191)
#  landing_variant  :string(191)
#  visit_id         :integer
#

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
