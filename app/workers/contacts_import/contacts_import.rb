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
    update_contacts = []
    create_contacts = []

    contacts_data = CSV.parse(file_content, :headers => true)

    domains = create_domains(contacts_data)
    create_websites(domains)

    to_update = get_contacts_to_update(contacts_data)
    contacts_data.each do |row|
      domain = domains[row['domain']] if row['domain'].present?
      if to_update[row['employee_email']].present?
        current_contact = to_update[row['employee_email']]
        update_contacts << update_clearbit_contact(current_contact, domain, row)
      else
        create_contacts << create_new_clearbit_contact(row, domain)
      end
    end

    begin
      ActiveRecord::Base.transaction do
        ClearbitContact.import update_contacts, on_duplicate_key_update: [:given_name, :family_name, :linkedin, :email, :title, :domain_datum_id, :quality]
      end
    rescue => p
      MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: "update_contacts: #{p.to_s}")
    end

    begin
      ActiveRecord::Base.transaction do
        ClearbitContact.import create_contacts
      end
    rescue => p
      MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: "create_contacts: #{p.to_s}")
    end

    created_contacts = ClearbitContact.where(email: create_contacts.map{|c| c.email}).pluck(:email)
    difference = (created_contacts.to_set - create_contacts.map{|c| c.email}.to_set).to_a
    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: difference.to_s) unless difference.empty?
  end

  def create_domains(contacts)
    create_domains = []
    all_contacts_domains = []
    contacts.each do |row|
      next unless row["domain"].present?
      all_contacts_domains << row["domain"]
      create_domains << DomainDatum.new(name: row["domain"], domain: row["domain"]) unless DomainDatum.exists?(domain: row["domain"])
    end
    ActiveRecord::Base.transaction do
      results = DomainDatum.import create_domains unless create_domains.empty?
    end
    return DomainDatum.where({domain: all_contacts_domains}).index_by(&:domain)
  rescue => p
    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: "create_domains: #{p.to_s}")
  end

  def create_websites(domains)
    create_websites = []
    domains.values.each do |row|
      create_websites << Website.new(domain_datum: row, url: row.domain) unless Website.exists?(url: row.domain)
    end
    ActiveRecord::Base.transaction do
      Website.import create_websites unless create_websites.empty?
    end
  rescue => p
    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: "create_websites: #{p.to_s}")
  end

  def get_contacts_to_update(contacts)
    contacts_linkedin = []
    contacts_email = []
    contacts.each do |row|
      contacts_linkedin << get_linkedin_data(row["employee_li"]) if row["employee_li"].present?
      contacts_email << row['employee_email']
    end
    contacts_by_email = ClearbitContact.where({email: contacts_email}).index_by(&:email)
    contacts_by_linkedin = ClearbitContact.where({linkedin: contacts_linkedin}).where.not({email: contacts_email}).index_by(&:email)
    contacts_by_domain = {}
    contacts.each do |row|
      next if contacts_by_email[row['employee_email']].present? or contacts_by_linkedin[row['employee_li']].present?
      next unless row["domain"].present?
      query_where = 'domain_data.domain = :domain '
      query_where += 'AND lower(clearbit_contacts.given_name) = :given_name ' if row["employee_first_name"].present?
      query_where += 'AND lower(clearbit_contacts.family_name) = :family_name' if row["employee_last_name"].present?

      where_params = {
        domain: row["domain"],
        given_name: row["employee_first_name"].andand.downcase,
        family_name: row["employee_last_name"].andand.downcase
      }.compact
      
      contacts_by_domain[row['employee_email']] = ClearbitContact.joins(:domain_datum).where(query_where, where_params).first
    end
    return contacts_by_email.merge(contacts_by_linkedin).merge(contacts_by_domain)
  end

  def update_clearbit_contact(cb_contact, domain, new_data)
    cb_contact.given_name = new_data["employee_first_name"] unless cb_contact.given_name.present?
    cb_contact.family_name = new_data["employee_last_name"] unless cb_contact.family_name.present?
    cb_contact.linkedin = new_data["employee_li"].andand.truncate(190) unless cb_contact.linkedin.present?
    cb_contact.email = new_data["employee_email"] unless cb_contact.email.present?
    cb_contact.title = new_data["employee_title"].andand.truncate(190) unless cb_contact.title.present?
    cb_contact.domain_datum_id = domain.andand.id unless cb_contact.domain_datum_id.present?
    cb_contact.quality = new_data["employee_email_confidence"] unless new_data["employee_email_confidence"].present?
    
    return cb_contact if cb_contact.changed?
  end

  def create_new_clearbit_contact(contact, domain)
    new_contact = ClearbitContact.new
    new_contact.given_name = contact["employee_first_name"]
    new_contact.family_name = contact["employee_last_name"]
    new_contact.linkedin = contact["employee_li"].andand.truncate(190)
    new_contact.email = contact["employee_email"]
    new_contact.title = contact["employee_title"].andand.truncate(190)
    new_contact.quality = contact["employee_email_confidence"]
    new_contact.domain_datum = domain if domain

    return new_contact
  end

  def get_linkedin_data(contact_linkedin)
    linkedin = contact_linkedin.split("/").last
    linkedin.present? ? "in/#{linkedin}" : nil
  end
end
  