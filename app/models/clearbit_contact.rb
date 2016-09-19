class ClearbitContact < ActiveRecord::Base
  belongs_to :website

  def self.get_contacts(query, website)
    contacts = []
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
      if website
        clearbit_contact = ClearbitContact.find_or_create_by(website_id: website.id, clearbit_id: person.id)
        contact[:email] = clearbit_contact.email if clearbit_contact.email
        clearbit_contact.update_attributes(
                                given_name: person.name.try(:givenName), 
                                family_name: person.name.try(:familyName), 
                                full_name: person.name.try(:fullName), 
                                title: person.title, 
                                linkedin: person.linkedin)
      end
      contacts << contact
    end
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
