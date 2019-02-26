class ContactsImport
    # This class imports and validate contacts from a file to clearbit.
    # It pulls the input data from AWS S3.
    
    ######################## INSTRUCTIONS ################################
  
    # TODO instructions
    # rails runner -e test "ContactsImport.generate('employees_20.csv')"
  
    S3_REPORTS_BUCKET = 'findemails'

    class << self
  
      def generate(file_name='employees.csv.gz')
        file_content = MightyAws::S3.new.retrieve( bucket: S3_REPORTS_BUCKET, key_path: file_name )

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

        File.delete(file_name) if File.exist?(file_name)

      end
  
      def get_clearbit_contact(contact)
        linkedin = get_linkedin_data(contact)
        
        contacts_query = ClearbitContact.arel_table[:email].eq(contact["employee_email"])
        unless linkedin.nil?
          contacts_query.or(ClearbitContact.arel_table[:linkedin].eq(linkedin))
        end
        contact_match = ClearbitContact.where(contacts_query).first
        if contact_match.nil?
          contact_match = get_contact_by_domain(contact)
        end
        contact_match
      end

      def get_contact_by_domain(contact)
        match_contact = nil
        contacts_by_domain = ClearbitContact.joins(:domain_datum).where(
          DomainDatum.arel_table[:domain].eq(contact["domain"]),
          ClearbitContact.arel_table[:given_name].lower.eq(contact["employee_first_name"].downcase),
          ClearbitContact.arel_table[:family_name].lower.eq(contact["employee_last_name"].downcase)
        ).first
        
        contacts_by_domain
      end 
  
      def update_clearbit_contact(cb_contact, new_data)
        unless new_data["employee_first_name"].nil?
          cb_contact.given_name = (cb_contact.given_name.nil? || cb_contact.given_name.empty?) ? new_data["employee_first_name"] : cb_contact.given_name
        end
        unless new_data["employee_last_name"].nil?
          cb_contact.family_name = (cb_contact.family_name.nil? || cb_contact.family_name.empty?) ? new_data["employee_last_name"] : cb_contact.family_name
        end
        unless new_data["employee_li"].nil?
          cb_contact.linkedin = (cb_contact.linkedin.nil? || cb_contact.linkedin.empty?) ? new_data["employee_li"] : cb_contact.linkedin
        end
        unless new_data["employee_email"].nil?
          cb_contact.email = (cb_contact.email.nil? || cb_contact.email.empty?) ? new_data["employee_email"] : cb_contact.email
        end
        unless new_data["employee_title"].nil?
          cb_contact.title = new_data["employee_title"].truncate(190) if cb_contact.title.nil? || cb_contact.title.empty?
        end
        unless new_data["domain"].nil?
          domain = cb_contact.domain_datum_id || DomainDatum.find_or_create_by(:domain => new_data["domain"]).id
          cb_contact.domain_datum_id = domain
        end
        unless new_data["employee_email_confidence"].nil?
          cb_contact.quality = new_data["employee_email_confidence"]
        end

        ClearbitContact.transaction do
          cb_contact.save()
        end
      rescue ActiveRecord::StatementInvalid
        p "Error updating contact #{cb_contact.email}"
      end
  
      def create_new_clearbit_contact(contact)
        new_contact = ClearbitContact.new
        unless contact["employee_first_name"].nil?
          new_contact.given_name = contact["employee_first_name"]
        end
        unless contact["employee_last_name"].nil?
          new_contact.family_name = contact["employee_last_name"]
        end
        unless contact["employee_li"].nil?
          new_contact.linkedin = contact["employee_li"]
        end
        unless contact["employee_email"].nil?
          new_contact.email = contact["employee_email"]
        end
        unless contact["employee_title"].nil?
          new_contact.title = contact["employee_title"].truncate(190)
        end
        unless contact["employee_email_confidence"].nil?
          new_contact.quality = contact["employee_email_confidence"]
        end
        unless contact["domain"].nil?
          domain = DomainDatum.find_or_create_by(:domain => contact["domain"])
          new_contact.domain_datum_id = domain.id
        end
  
        ClearbitContact.transaction do
          new_contact.save()
        end
      rescue ActiveRecord::StatementInvalid
        p "Error creating contact #{contact["employee_email"]}"
      end
  
      def get_linkedin_data(contact)
        if !contact["employee_li"].nil?
          linkedin = contact["employee_li"].split("/").last
          unless linkedin.nil?
            "in/#{linkedin}"
          end
        end
      end
    end
  end
  