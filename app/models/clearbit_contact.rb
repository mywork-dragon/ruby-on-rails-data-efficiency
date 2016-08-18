class ClearbitContact < ActiveRecord::Base
  belongs_to :website

  def self.get_contacts(query, website)
    contacts = []
    people = Clearbit::Prospector.search(query)

    people.each do |person|
      contacts << {
        clearBitId: person.id,
        givenName: person.name.try(:givenName),
        familyName: person.name.try(:familyName),
        fullName: person.name.try(:fullName),
        title: person.title,
        email: person.email,
        linkedin: person.linkedin
      }

      # save as new records to DB
      if website
        clearbit_contact = ClearbitContact.find_or_create_by(website_id: website.id, clearbit_id: person.id)
        clearbit_contact.update_attributes(
                                given_name: person.name.try(:givenName), 
                                family_name: person.name.try(:familyName), 
                                full_name: person.name.try(:fullName), 
                                title: person.title, 
                                email: person.email, 
                                linkedin: person.linkedin)
      end
    end
    contacts
  end

  def as_json
    {
      clearBitId: clearbit_id,
      givenName: given_name,
      familyName: family_name,
      fullName: full_name,
      title: title,
      email: email,
      linkedin: linkedin
    }
  end
end
