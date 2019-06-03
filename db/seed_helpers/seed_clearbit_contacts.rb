def seed_clearbit_contacts
  puts "creating ClearbitContacts"
  disable_logging
  Website.all.each do |web|
    given_name  = Faker::Name.first_name
    family_name = Faker::Name.last_name
    ClearbitContact.find_or_initialize_by(email: Faker::Internet.email).tap do |cc|
      cc.given_name  = given_name
      cc.family_name = family_name
      cc.full_name   = "#{given_name} #{family_name}"
      cc.quality     = rand(1..10)
      cc.linkedin    = "http://linkedin/#{Faker::Internet.username}"
      cc.title       = "#{Faker::Company.industry} #{Faker::Company.profession}"
      cc.website     = web
      cc.website.domain_datum = DomainDatum.where(domain: web.domain).first_or_create(domain: web.domain)
      cc.save
    end
  end
ensure
  puts "Created Contacts: #{ClearbitContact.count} with DomainDatum: #{DomainDatum.count}"
  enable_logging
end
