require_relative 'conf_logging'
def seed_ios_developers
  total = 5
  puts 'Creating IosDevelopers'
  disable_logging
  for i in 1..total
    i == total ? puts('.') : print('.')
    IosDeveloper.create(name: Faker::Company.name)
  end
ensure
  puts "Created Ios Developers: #{IosDeveloper.count}"
  enable_logging
end
