def seed_companies
  puts "creating companies"
  total = 20
  for i in 1..total
    i == total ? puts('.') : print('.')

    attributes = {
      name: Faker::Company.name,
      street_address: Faker::Address.street_address,
      city: Faker::Address.city,
      zip_code: Faker::Address.zip_code,
      state: Faker::Address.state_abbr,
      country: Faker::Address.country,
      funding: rand(0..100000000)
    }
    attributes.merge!(fortune_1000_rank: i) if i.even?

    Company.create attributes
  end
end
