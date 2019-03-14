class ContactsExportWorker

  include Sidekiq::Worker

  sidekiq_options queue: :contacts_export, retry: true

  S3_REPORTS_BUCKET = ''
  S3_INPUT_PATH = ''

  def perform(publiser_id, filter)

    developer = if platform == 'ios' 
      IosDeveloper.find(publisher_id)
    else
      AndroidDeveloper.find(publisher_id)
    end

    contacts = ContactDiscoveryService.new.get_contacts_for_developer(developer, filter)

    header = ['MightySignal ID', 'Company Name', 'Title', 'Full Name', 'First Name', 'Last Name', 'Email', 'LinkedIn']
    companyName = 'tbd' #TODO

    file_name = "contacts_#{publisher_id}.csv"

    list_csv = CSV.open(file_name, "w+") do |csv|
      csv << header
      contacts.each do |contact|
        contact = contact.with_indifferent_access
        contacts_hash = [
          contact['clearbitId'],
          companyName,
          contact['title'],
          contact['fullName'],
          contact['givenName'],
          contact['familyName'],
          contact['email'],
          contact['linkedin']
        ]
        csv << contacts_hash
      end
    end

    MightyAws::S3.new.retrieve( bucket: S3_REPORTS_BUCKET, key_path: S3_INPUT_PATH + file_name )
    
    # TODO update the job status

  rescue 
    p "Error"
  ensure
    # output_file.close unless output_file.nil?
  end

end