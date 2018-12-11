# == Schema Information
#
# Table name: clearbit_contacts
#
#  id              :integer          not null, primary key
#  website_id      :integer
#  clearbit_id     :string(191)
#  given_name      :string(191)
#  family_name     :string(191)
#  full_name       :string(191)
#  title           :string(191)
#  email           :string(191)
#  linkedin        :string(191)
#  updated         :date
#  created_at      :datetime
#  updated_at      :datetime
#  domain_datum_id :integer
#

# DEPRECATED model/class methods
# we now rely on the mightybit (lense) service.

class ClearbitContact < ActiveRecord::Base
  belongs_to :website
  belongs_to :domain_datum

  def self.get_contacts(domain:, title: nil, limit: 5)
    contacts = []
    
    query = {domain: domain, limit: limit}
    query[:title] = title if title
    
    people = Clearbit::Prospector.search(query)

    people.each do |person|
      contact = {
        clearbitId: person.id,
        givenName: person.name.try(:givenName),
        familyName: person.name.try(:familyName),
        fullName: person.name.try(:fullName),
        title: person.title,
        linkedin: person.linkedin
      }

      # save as new records to DB
      domain_datum = DomainDatum.find_or_create_by(domain: domain)
      clearbit_contact = ClearbitContact.find_or_create_by(clearbit_id: person.id)
      contact[:email] = clearbit_contact.email if clearbit_contact.email
      clearbit_contact.update_attributes(
                              given_name: person.name.try(:givenName), 
                              family_name: person.name.try(:familyName), 
                              full_name: person.name.try(:fullName), 
                              title: person.title, 
                              linkedin: person.linkedin)
      domain_datum.clearbit_contacts << clearbit_contact unless domain_datum.clearbit_contacts.include? clearbit_contact
      contacts << contact
    end
    contacts
  end

  def self.get_contacts_for_developer(developer, filter)
    contacts = []
    domains = {}

    websites = developer.valid_websites.map{|website| website.url}
    websites << developer.try(:ios_apps).try(:first).try(:support_url) if developer.try(:ios_apps).try(:first).try(:support_url)
    websites << developer.try(:android_apps).try(:first).try(:support_url) if developer.try(:android_apps).try(:first).try(:support_url)

    # takes up to five websites associated with company & creates array of clearbit_contacts objects
    websites.first(5).each do |url|
      domain = UrlHelper.url_with_domain_only(url)

      valid_developer_ids = if developer.is_a?(IosDeveloper)
        ClearbitWorker::IOS_DEVELOPER_IDS[domain]
      else 
        ClearbitWorker::ANDROID_DEVELOPER_IDS[domain]
      end

      next if domain.blank? || domains[domain] || (valid_developer_ids && !valid_developer_ids.include?(developer.id))
      domains[domain] = 1

      domain_datum = DomainDatum.where(domain: domain).first

      if filter.present?
        contacts += domain_datum.clearbit_contacts.where("title LIKE ?", "%#{filter}%").as_json if domain_datum
        begin
          contacts += ClearbitContact.get_contacts(domain: domain, title: filter, limit: 20)
        rescue
        end
      else
        current_contacts =  if domain_datum
                              domain_datum.clearbit_contacts.where(updated_at: Time.now-60.days..Time.now).
                              where("email IS NULL OR email != 'No Email'").as_json
                            else
                              []
                            end

        if current_contacts.count < 20
          begin
            current_contacts += ClearbitContact.get_contacts(domain: domain, title: 'product', limit: 20)
            current_contacts += ClearbitContact.get_contacts(domain: domain, limit: 20)
            current_contacts += ClearbitContact.get_contacts(domain: domain, title: 'marketing', limit: 20)
          rescue
          end
        end

        contacts += current_contacts
      end
    end
    
    contacts.uniq! {|e| e[:clearbitId] }
    contacts
  end

  def self.get_contact_email(person_id)

    if ServiceStatus.is_active?(:clearbit_contact_service)
      get = HTTParty.get("https://prospector.clearbit.com/v1/people/#{person_id}/email", headers: {'Authorization' => 'Bearer 229daf10e05c493613aa2159649d03b4'})
      email = JSON.load(get.response.body).try(:[], "email") || "No Email"
      if ClearbitContact.where(clearbit_id: person_id).any?
        contacts = ClearbitContact.where(clearbit_id: person_id)
        contacts.update_all(email: email) if email
      end
      email
    else
      # Use MightyBit - our own clearbit alternative.
      contact = ClearbitContact.where(clearbit_id: person_id).first
      if contact.domain_datum.present?
        domain = contact.domain_datum.domain
      else
        domain = URI.parse(contact.website.url).host.downcase
      end
      auth_token = ENV['MIGHTYBIT_API_TOKEN'].to_s
      full_name = URI.encode(contact.full_name)
      resp = JSON.load(HTTParty.get("http://mightybitweb-384573877.us-east-1.elb.amazonaws.com/v1/email?name=#{full_name}&domain=#{domain}", headers: { 'Authorization' => auth_token }))
      if resp['status'] == 'success'
        return resp['email']
      end
      resp['domain'] = domain
      Rails.logger.info(resp)
      "No Email"
    end

  end

  def as_json(options={})
    {
      clearbitId: clearbit_id,
      givenName: given_name,
      familyName: family_name,
      fullName: full_name,
      title: title,
      email: email,
      linkedin: linkedin
    }
  end
end
