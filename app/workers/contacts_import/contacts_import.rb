require 'digest'
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
  POOL_SIZE   = 4 #Tied to DB connections pool in database.yml pool: 5 (must be less than those)

  def perform(file_name, file_content)

    contacts_data = CSV.parse(file_content, :headers => true)
    websites_index = {}

    contacts_to_save = Queue.new
    ClearbitContact.transaction do
      contacts_data.each do |contact_raw|
        contacts_to_save.push ClearbitContact.find_or_initialize_by(email: contact_raw['employee_email']).tap do |contact_obj|
          website_digest            = Digest::MD5.hexdigest "http://#{contact_raw["domain"]}-#{contact_raw["domain"]}"
          contact_obj.given_name    = contact_raw["employee_first_name"]                 if contact_raw["employee_first_name"].present?
          contact_obj.family_name   = contact_raw["employee_last_name"]                  if contact_raw["employee_last_name"].present?
          contact_obj.full_name     = "#{contact_raw["employee_first_name"]} #{contact_raw["employee_last_name"]}".strip
          contact_obj.linkedin      = contact_raw["employee_li"].andand.truncate(190)    if contact_raw["employee_li"].present?
          contact_obj.email         = contact_raw["employee_email"]                      if contact_raw["employee_email"].present?
          contact_obj.title         = contact_raw["employee_title"].andand.truncate(190) if contact_raw["employee_title"].present?
          contact_obj.quality       = contact_raw["employee_email_confidence"]           if contact_raw["employee_email_confidence"].present?
          contact_obj.website       = websites_index[website_digest] ||
                                      Website.find_or_create_by!(url: "http://#{contact_raw["domain"]}", domain: contact_raw["domain"]).tap do |web|
                                        websites_index[website_digest] = web
                                      end
          contact_obj.website.domain_datum  = DomainDatum.find_or_initialize_by(domain: contact_raw["domain"])
        end
      end

      threads = Array.new(POOL_SIZE) do
        Thread.new do
          begin
            while contact_to_save = contacts_to_save.pop(true)
              contact_to_save.save!
            end
          rescue ThreadError => e
            raise e unless e.message == "queue empty"
          end
        end
      end
      threads.map(&:join)
    end

  rescue StandardError => e
    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: file_name)
  end
end
