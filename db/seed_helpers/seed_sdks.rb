def seed_sdks
  disable_logging

  puts 'creating Sdks'
  100.times do |i|
    IosSdk.create(
      name: Faker::Company.name + i.to_s,
      website: Faker::Internet.url,
      favicon: Faker::Avatar.image,
      summary: Faker::Company.catch_phrase,
      kind: 0,
      open_source: false
    )
  end
  100.times do |i|
    AndroidSdk.create(
      name: Faker::Company.name + i.to_s,
      website: Faker::Internet.url,
      favicon: Faker::Avatar.image,
      summary: Faker::Company.catch_phrase,
      kind: 0,
      open_source: false
    )
  end
ensure
  enable_logging
end
