class ContactsImport
  # This class imports and validate contacts from a file to clearbit.
  # It pulls the input data from AWS S3.
  
  ######################## INSTRUCTIONS ################################

  # This script is executed as a rake tasks as follow:
  # rake contacts:import

  include Sidekiq::Worker

  class << self

  end

  def perform(file_content)

    contacts_data = CSV.parse(file_content, :headers => true)

    p "contacts: #{contacts_data.length}"

    contacts_data.each do |row|
      p row["employee_email"]
      contact_match = get_clearbit_contact(row)
      if contact_match.nil?
        p "create new clearbit contact"
        create_new_clearbit_contact(row)
      else
        p "update clearbit contact"
        update_clearbit_contact(contact_match, row)
      end
    end
  end

  def get_clearbit_contact(contact)
    linkedin = get_linkedin_data(contact)

    query_where = "email = :email"
    query_where_params = {:email => contact["employee_email"]}
    unless linkedin.nil?
      query_where = query_where + " or linkedin = :linkedin"
      query_where_params[:linkedin] =  linkedin
    end

    contact_match = ClearbitContact.where(query_where, query_where_params).first

    if contact_match.nil?
      query_where = 'domain_data.domain = :domain '
      where_params = {
        domain: contact[:domain]
      }
      if contact[:employee_first_name].present?
        query_where += 'AND lower(clearbit_contacts.given_name) = :given_name '
        where_params[:given_name] = ontact[:employee_first_name].downcase
      end
      if contact[:employee_last_name].present?
        query_where += 'AND lower(clearbit_contacts.family_name) = :family_name'
        where_params[:family_name] = ontact[:employee_last_name].downcase
      end

      contact_match = ClearbitContact.joins(:domain_datum).where(query_where, where_params).first
    end
    contact_match
  end

  def update_clearbit_contact(cb_contact, new_data)
    unless cb_contact.given_name.present?
      cb_contact.given_name = new_data["employee_first_name"]
    end
    unless cb_contact.family_name.present?
      cb_contact.family_name = new_data["employee_last_name"]
    end
    unless cb_contact.linkedin.present?
      cb_contact.linkedin = new_data["employee_li"]
    end
    unless cb_contact.email.present?
      cb_contact.email = new_data["employee_email"]
    end
    unless cb_contact.title.present?
      cb_contact.title = new_data["employee_title"].andand.truncate(190)
    end
    unless cb_contact.domain_datum_id.present?
      cb_contact.domain_datum_id = DomainDatum.find_or_create_by(:domain => new_data["domain"]).andand.id
    end
    
    cb_contact.quality = new_data["employee_email_confidence"]

    cb_contact.save()
  rescue ActiveRecord::StatementInvalid
    p "Error updating contact #{cb_contact.email}"
  end

  def create_new_clearbit_contact(contact)
    new_contact = ClearbitContact.new
    new_contact.given_name = contact["employee_first_name"]
    new_contact.family_name = contact["employee_last_name"]
    new_contact.linkedin = contact["employee_li"]
    new_contact.email = contact["employee_email"]
    new_contact.title = contact["employee_title"].andand.truncate(190)
    new_contact.quality = contact["employee_email_confidence"]
    new_contact.domain_datum_id = DomainDatum.find_or_create_by(:domain => contact["domain"]).andand.id

    new_contact.save()
  rescue ActiveRecord::StatementInvalid
    p "Error creating contact #{contact["employee_email"]}"
  end

  def get_linkedin_data(contact)
    if contact["employee_li"].present?
      linkedin = contact["employee_li"].split("/").last
      linkedin.present? ? "in/#{linkedin}" : nil
    end
  end
end
  