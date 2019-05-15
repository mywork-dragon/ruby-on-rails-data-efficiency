def seed_android_developers
  total = 5
  puts 'Creating AndroidDevelopers'
  disable_logging
  for i in 1..total
    i == total ? puts('.') : print('.')
    AndroidDeveloper.create(name: Faker::Company.name)
  end
ensure
  enable_logging
end
