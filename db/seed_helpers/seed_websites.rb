def seed_websites
  disable_logging
  total = 200
  puts "creating websites, and linking them to companies, ios apps"
    for i in 1..total
      begin
        website = Website.find_or_create_by(url: Faker::Internet.domain_name + i.to_s, kind: :primary)
        ios_app = IosApp.all.sample
        ios_app = IosApp.includes(websites: :company).where(id: ios_app.id).first
        company = ios_app.get_company.blank? ? Company.all.sample : ios_app.get_company
        company.websites << website
        ios_app.websites << website
        i == total ? puts('.') : print('.')
      rescue
      end
  end

  puts "creating websites, and linking them to companies, android apps"

  for i in 1..total
    begin
      website = Website.find_or_create_by(url: Faker::Internet.domain_name + i.to_s, kind: :primary)
      android_app = AndroidApp.all.sample
      android_app = AndroidApp.includes(websites: :company).where(id: android_app.id).first
      company = android_app.get_company.blank? ? Company.all.sample : android_app.get_company
      company.websites << website
      android_app.websites << website
      i == total ? puts('.') : print('.')
    rescue
    end
  end
ensure
  enable_logging
end
