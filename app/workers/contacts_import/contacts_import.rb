require 'digest'
require 'benchmark'
class ContactsImport
  # This class imports and validate contacts from a file to clearbit.
  # It pulls the input data from AWS S3.

  ######################## INSTRUCTIONS ################################

  # This script is executed as a rake tasks as follow:
  # rake contacts:import[number_files,file_prefix]
  # Ex: rake contacts:import[10,contacts] #no space after comma.

  include Sidekiq::Worker

  sidekiq_options queue: :contacts_upload, retry: true

  STREAM_NAME = 'contacts_import'

  def perform(file_name, file_content)
    puts Benchmark.measure {


    contacts_data = CSV.parse(file_content, :headers => true)
    headers, *contacts_data = contacts_data.to_a
    fields_map = headers.each_with_index.inject({}){|memo,(name, position)| memo[name] = position and memo }

    websites_index = {}
    contacts_to_save = []

    ClearbitContact.transaction do
      old_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil

      contacts_to_save = contacts_data.map do |contact_raw|
        employee_email = contact_raw[fields_map[ 'employee_email'           ]].presence
        given_name     = contact_raw[fields_map[ 'employee_first_name'      ]].presence
        family_name    = contact_raw[fields_map[ 'employee_last_name'       ]].presence
        linkedin       = contact_raw[fields_map[ 'employee_li'              ]].presence
        title          = contact_raw[fields_map[ 'employee_title'           ]].presence
        quality        = contact_raw[fields_map[ 'employee_email_confidence']].presence
        domain         = contact_raw[fields_map[ 'domain'                   ]].presence

        ClearbitContact.find_or_initialize_by(email: employee_email).tap do |contact_obj|
          website_digest            = Digest::MD5.hexdigest "http://#{domain}-#{domain}"
          contact_obj.full_name     = "#{given_name} #{family_name}".strip.presence

          contact_obj.given_name    = given_name     if given_name
          contact_obj.family_name   = family_name    if family_name
          contact_obj.email         = employee_email if employee_email
          contact_obj.quality       = quality        if quality
          contact_obj.linkedin      = linkedin.andand.truncate(190) if linkedin
          contact_obj.title         = title.andand.truncate(190)    if title

          contact_obj.website       = websites_index[website_digest] ||
                                      Website.find_or_create_by!(url: "http://#{domain}", domain: domain).tap do |web|
                                        websites_index[website_digest] = web
                                      end

          contact_obj.website.domain_datum  = DomainDatum.find_or_initialize_by(domain: domain)
        end
      end
      ActiveRecord::Base.logger = old_logger
      result = ClearbitContact.import contacts_to_save, on_duplicate_key_update: [:given_name, :family_name, :linkedin, :email, :title, :quality]
    end

  }

  rescue StandardError => e
    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: file_name)
  end

end
