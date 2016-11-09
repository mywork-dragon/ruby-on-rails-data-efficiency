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

      if filter.present?
        contacts += ClearbitContact.get_contacts(domaim: domain, title: filter, limit: 20)
      else
        domain_datum = DomainDatum.where(domain: domain).first
        current_contacts =  domain_datum ? domain_datum.clearbit_contacts.where(updated_at: Time.now-60.days..Time.now).as_json : []

        if current_contacts.count < 20
          current_contacts += ClearbitContact.get_contacts(domain: domain, title: 'product', limit: 20)
          current_contacts += ClearbitContact.get_contacts(domain: domain, limit: 20)
          current_contacts += ClearbitContact.get_contacts(domain: domain, title: 'marketing', limit: 20)
        end

        contacts += current_contacts
      end
    end
    contacts.uniq! {|e| e[:clearbitId] }
    contacts
  end

  def self.get_contact_email(person_id)
    get = HTTParty.get("https://prospector.clearbit.com/v1/people/#{person_id}/email", headers: {'Authorization' => 'Bearer 229daf10e05c493613aa2159649d03b4'})
    email = JSON.load(get.response.body).try(:[], "email") || "No Email"
    if ClearbitContact.where(clearbit_id: person_id).any?
      contacts = ClearbitContact.where(clearbit_id: person_id)
      contacts.update_all(email: email) if email
    end
    email
  end

  def as_json
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
