# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


File.readlines(Rails.root + "db/bizible/companies.txt").each do |l|
  l.strip!
  Company.create(
    name: l,
    website: l.match(/^http[s]*:\/\//) ? l : "http://" + l,
    status: :active
  )
end

Dir[Rails.root + "db/bizible/services/*.txt"].each do |f|
  category = File.basename(f, ".*").titlecase
  File.readlines(f).each do |l|
    Service.create(
      name: l.strip,
      category: category
    )
  end
end


# cbs
Matcher.create(
  service: Service.find_by_name("Optimizely"),
  match_type: :regex,
  match_string: "cdn.optimizely.com\/js\/([^.]+).js"
)

# adroll
Matcher.create(
  service: Service.find_by_name("Olark"),
  match_type: :regex,
  match_string: "olark.identify\(([^)]+)\)"
)