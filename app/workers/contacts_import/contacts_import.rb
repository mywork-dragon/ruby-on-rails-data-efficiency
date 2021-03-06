require 'digest'
class ContactsImport
  # This class imports and validate contacts from a file to clearbit.
  # It pulls the input data from AWS S3.

  ######################## INSTRUCTIONS ################################

  # This script is executed as a rake tasks as follow:
  # rake contacts:import[number_files,file_prefix]
  # Ex: rake contacts:import[10,contacts,1] #no space after comma.

  include Sidekiq::Worker

  sidekiq_options queue: :contacts_upload #Dont retry. If fail then success logged as failed first time.

  STREAM_NAME = 'contacts_import'
  MAX_RETRIES = 5

  def perform(file_name, file_content)
    print_to_screen = true
    contacts_data = CSV.parse(file_content, :headers => true)
    headers, *contacts_data = contacts_data.to_a
    fields_map = headers.each_with_index.inject({}){|memo,(name, position)| memo[name] = position and memo }

    contacts_to_save = []
    websites = {}
    domains = {}
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      ClearbitContact.transaction do
        contacts_to_save = contacts_data.map do |contact_raw|
          print('**') if print_to_screen
          employee_email = contact_raw[fields_map[ 'employee_email'           ]].presence
          given_name     = contact_raw[fields_map[ 'employee_first_name'      ]].presence
          family_name    = contact_raw[fields_map[ 'employee_last_name'       ]].presence
          linkedin       = contact_raw[fields_map[ 'employee_li'              ]].presence
          title          = contact_raw[fields_map[ 'employee_title'           ]].presence
          quality        = contact_raw[fields_map[ 'employee_email_confidence']].presence
          domain         = contact_raw[fields_map[ 'domain'                   ]].presence

          cbc = ClearbitContact.find_or_initialize_by(email: employee_email).tap do |contact_obj|
      	    print('=') if print_to_screen
            website_digest            = Digest::MD5.hexdigest "http://#{domain}-#{domain}"
      	    domain_digest             = Digest::MD5.hexdigest domain
            contact_obj.full_name     = "#{given_name} #{family_name}".strip.presence

            contact_obj.given_name    = given_name     if given_name
            contact_obj.family_name   = family_name    if family_name
            contact_obj.email         = employee_email if employee_email
            contact_obj.quality       = quality        if quality
            contact_obj.linkedin      = linkedin.andand.truncate(190) if linkedin
            contact_obj.title         = title.andand.truncate(190)    if title
            begin
      	      print('~1') if print_to_screen
              contact_obj.website    =  websites[website_digest] ||
                                        Website.where('url=? OR domain=?', "http://#{domain}", domain: domain).first_or_create(url: "http://#{domain}", domain: domain).tap do |web|
					                                websites[website_digest] = web
                                        end
            rescue ActiveRecord::RecordNotUnique
              retry
            end

            begin
              print('~2') if print_to_screen
              contact_obj.website.domain_datum  = domains[domain_digest] ||
                                                  DomainDatum.where(domain: domain).first_or_create(domain: domain).tap do |dd|
                                                    domains[domain_digest] =  dd
                                                  end
            rescue ActiveRecord::RecordNotUnique
              retry
            end
      	    print('=') if print_to_screen
          end
      	  p('**') if print_to_screen
      	  cbc
        end
        ClearbitContact.import contacts_to_save, on_duplicate_key_update: [:given_name, :family_name, :linkedin, :email, :title, :quality]
      end
    rescue Mysql2::Error, Redis::TimeoutError => error
      ActiveRecord::Base.logger = old_logger
      @retries ||= 0
      if @retries < MAX_RETRIES
        @retries += 1
        logger.error("Retry #{@retries}:  #{file_name} = #{error.message}")
        retry
      else
        raise error
      end
    end
  rescue StandardError => e
    ActiveRecord::Base.logger = old_logger
    logger.error("#{file_name} = #{e.message}")
    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: "#{file_name} - Error: #{e.message}")
  ensure
    ActiveRecord::Base.logger = old_logger
  end

end
