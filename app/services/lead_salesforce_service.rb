class LeadSalesforceService

  def initialize
    @client = Restforce.new(
      username: 'jasonlew@mightysignal.com',
      password: 'Welcome@2',
      security_token: 'tZ2A3mEmKhxjWdP98HcoaUGB',
      client_id: '3MVG9fMtCkV6eLhcIlf3UM3DhI0qHjleFYx1eiGwILdwEf8djU26Vnqjd3mu1Kxs0Z258R99eC0sfRJHG548g',
      client_secret: '6384884061761347258'
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
    lead_data
  end

  class << self

    def add_to_salesforce(data)
      LeadSalesforceService.new.add_to_salesforce(data)
    end

  end

end