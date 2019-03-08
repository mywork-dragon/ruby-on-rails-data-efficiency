class ContactsImport
  # This class imports and validate contacts from a file to clearbit.
  # It pulls the input data from AWS S3.
  
  ######################## INSTRUCTIONS ################################

  # This script is executed as a rake tasks as follow:
  # rake contacts:import[file_prefix, number_files]
  # Ex: rake contacts:import[contacts, 10]

  include Sidekiq::Worker
  
  sidekiq_options queue: :contacts_upload, retry: true

  STREAM_NAME = 'contacts_import'


  def perform(file_content)

    contacts_data = CSV.parse(file_content, :headers => true)

    p "contacts: #{contacts_data.length}"

    contacts_data.each do |row|
      MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: row["employee_email"])
      contact_match = get_clearbit_contact(row)
      contact_match.present? ? update_clearbit_contact(contact_match, row) : create_new_clearbit_contact(row)
    end
  end

  def get_clearbit_contact(contact)
    linkedin = get_linkedin_data(contact["employee_li"]) if contact["employee_li"].present?

    query_where = "email = :email"
    query_where_params = {:email => contact["employee_email"]}
    
    query_where += " or linkedin = :linkedin" if linkedin
    query_where_params[:linkedin] =  linkedin if linkedin

    contact_match = ClearbitContact.where(query_where, query_where_params).first

    return contact_match if contact_match

    if contact[:domain].present?
      query_where = 'domain_data.domain = :domain '
      query_where += 'AND lower(clearbit_contacts.given_name) = :given_name ' if contact[:employee_first_name].present?
      query_where += 'AND lower(clearbit_contacts.family_name) = :family_name' if contact[:employee_last_name].present?

      where_params = {
        domain: contact[:domain],
        given_name: contact[:employee_first_name].andand.downcase,
        family_name: contact[:employee_last_name].andand.downcase
      }.compact
      
      contact_match = ClearbitContact.joins(:domain_datum).where(query_where, where_params).first
    end

    contact_match
  end

  def update_clearbit_contact(cb_contact, new_data)
    cb_contact.given_name = new_data["employee_first_name"] unless cb_contact.given_name.present?
    cb_contact.family_name = new_data["employee_last_name"] unless cb_contact.family_name.present?
    cb_contact.linkedin = new_data["employee_li"] unless cb_contact.linkedin.present?
    cb_contact.email = new_data["employee_email"] unless cb_contact.email.present?
    cb_contact.title = new_data["employee_title"].andand.truncate(190) unless cb_contact.title.present?
    cb_contact.domain_datum_id = find_or_create_domain_website(domain: new_data["domain"]).andand.id unless cb_contact.domain_datum_id.present?
    
    cb_contact.quality = new_data["employee_email_confidence"]

    if cb_contact.changed?
      MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: "Contact not updated: #{cb_contact.id}") unless cb_contact.save()
    end
  end

  def create_new_clearbit_contact(contact)
    new_contact = ClearbitContact.new
    new_contact.given_name = contact["employee_first_name"]
    new_contact.family_name = contact["employee_last_name"]
    new_contact.linkedin = contact["employee_li"]
    new_contact.email = contact["employee_email"]
    new_contact.title = contact["employee_title"].andand.truncate(190)
    new_contact.quality = contact["employee_email_confidence"]
    new_contact.domain_datum_id = find_or_create_domain_website(contact["domain"]).andand.id

    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data:"Contact not saved: #{contact['employee_email']}") unless new_contact.save()
  end

  def find_or_create_domain_website(domain)
    domain_datum = DomainDatum.find_by(domain: domain)
    return domain_datum if domain_datum

    domain_datum = DomainDatum.create(domain: domain)
    website = Website.create(domain_datum: domain_datum, url: domain_datum.domain) if domain_datum
    domain_datum
  end

  def get_linkedin_data(contact_linkedin)
    linkedin = contact_linkedin.split("/").last
    linkedin.present? ? "in/#{linkedin}" : nil
  end
end
  