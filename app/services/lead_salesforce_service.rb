class LeadSalesforceService

  def initialize
    @client = Restforce.new(
      username: ENV['RESTFORCE_USERNAME'].to_s,
      password: ENV['RESTFORCE_PASSWORD'].to_s,
      security_token: ENV['RESTFORCE_SECURITY_TOKEN'].to_s,
      client_id: ENV['RESTFORCE_CLIENT_ID'].to_s,
      client_secret: ENV['RESTFORCE_CLIENT_SECRET'].to_s
    )
  end

  def add_to_salesforce(data)
    data = data.with_indifferent_access
    if data[:email].present?
      if lead = @client.query("select Id, Company, FirstName, LastName, LeadSource, SDK__c, Message__c, Phone, Email from Lead where Email = '#{data[:email]}'").first
        @client.update('Lead', lead_hash(data, lead))
      else
        @client.create!('Lead', lead_hash(data))
      end
    end
  end

  def lead_hash(data, lead=nil)
    lead_data = {}
    lead_data['Id'] = lead.Id if lead
    lead_data['FirstName'] = data[:first_name] || 'not sure' if lead.blank? || lead.FirstName.blank?
    lead_data['LastName'] = data[:last_name] || 'not sure' if lead.blank? || lead.LastName.blank?
    lead_data['Company'] = data[:company] || 'not sure' if lead.blank? || lead.Company.blank?
    lead_data['LeadSource'] = data[:lead_source] if lead.blank? || lead.LeadSource.blank?
    lead_data['SDK__c'] = data[:sdk] if lead.blank? || lead.SDK__c.blank?
    lead_data['Message__c'] = data[:message] if lead.blank? || lead.Message__c.blank?
    lead_data['Phone'] = data[:phone] if lead.blank? || lead.Phone.blank?
    lead_data['Email'] = data[:email] if lead.blank? || lead.Email.blank?
    lead_data['MightySignalCreatedAt__c'] = data[:created_at].try(:iso8601) || Time.now.iso8601 if lead.blank? || lead.MightySignalCreatedAt__c.blank?
    lead_data
  end

  class << self

    def add_to_salesforce(data)
      LeadSalesforceService.new.add_to_salesforce(data)
    end

    def import_old_leads 
      Dir.glob('web_form/*').each do |file_name|
        file = File.read(file_name)
        data_hash = JSON.parse(file)
        data_hash.each do |message|
          next unless message["text"].start_with?('Web Form uploaded')
          if msg = message['file']['preview'].split('<br>')
            lead_data = {}
            msg.each do |field|
              field = field.gsub(/\r\n\s+/, "")
              if field.match(/^First Name: /)
                field.sub!(/^First Name: /, '')
                lead_data[:first_name] = field if field.present?
              elsif field.match(/^Last Name: /)
                field.sub!(/^Last Name: /, '')
                lead_data[:last_name] = field if field.present?
              elsif field.match(/^Company: /)
                field.sub!(/^Company: /, '')
                lead_data[:company] = field if field.present?
              elsif field.match(/^Email: /)
                field.sub!(/^Email: /, '')
                lead_data[:email] = field if field.present?
              elsif field.match(/^Phone: /)
                field.sub!(/^Phone: /, '')
                lead_data[:phone] = field if field.present?
              elsif field.match(/^iOS and\/or Android SDKs\?: /)
                field.sub!(/^iOS and\/or Android SDKs\?: /, '')
                lead_data[:sdk] = field if field.present?
              elsif field.match(/^Message: /)
                field.sub!(/^Message: /, '')
                lead_data[:message] = field if field.present?
              end
            end
            lead_data[:created_at] = Time.at(message['file']['timestamp'].to_i).utc
            if lead_data[:message] == 'Top SDKS page'
              lead_data[:lead_source] = 'Top SDKS page'
            else
              lead_data[:lead_source] = 'Web Form'
            end
            puts lead_data if lead_data[:email].present?
            begin
              SalesforceWorker.new.perform(:add_lead, lead_data) if lead_data[:email].present?
            rescue
              puts "Failed to import"
              puts lead_data
              next
            end
          end
        end
      end
    end

  end

end
