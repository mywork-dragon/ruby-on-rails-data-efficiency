class ContactDiscoveryService
  @@endpoint = "http://lense.mightysignal.com/v1/"

  def valid_developer_ids(developer, domain)
    if developer.is_a?(IosDeveloper)
      ClearbitWorker::IOS_DEVELOPER_IDS[domain]
    else 
      ClearbitWorker::ANDROID_DEVELOPER_IDS[domain]
    end
  end

  def is_valid_developer(developer, domain)
    ids = valid_developer_ids(developer, domain)
    !(ids && !ids.include?(developer.id))
  end

  def mightybit_get(path)
    auth_token = ENV['MIGHTYBIT_API_TOKEN'].to_s
    JSON.load(HTTParty.get(
      @@endpoint + path,
      headers: { 'Authorization' => auth_token }))
  end

  def get_contacts(domain:, title: nil, limit: 20)
    resp = mightybit_get("contacts?domain=#{domain}")
    contacts = resp['contacts'].map do | person |
      contact = {
        clearbitId: person['contact_id'],
        givenName: person['name']['givenName'],
        familyName: person['name']['familyName'],
        fullName: person['name']['fullName'],
        title: person['title'],
        linkedin: person['linkedin']
      }
    end
    if !title.nil? and !title.empty?
      contacts = contacts.select {|c| c[:title] && c[:title].downcase.include?(title.downcase)}
    end
    contacts.first(limit)
  end

  def get_contacts_for_developer(developer, filter)
    contacts = []
    domains = {}
    domains = developer.possible_contact_domains

    domains = domains.select {|x| is_valid_developer(developer, x)}

    contacts = domains.first(5).flat_map do |domain|
      self.get_contacts(:domain => domain, :title => filter)
    end
    contacts
  end

  def get_contact_email(person_id)
    resp = mightybit_get("people/#{person_id}/email")
    if resp['status'] == 'success'
      return resp['email']
    end
    "No Email"
  end

end
