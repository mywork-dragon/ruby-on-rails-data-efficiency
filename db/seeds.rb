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

# Dir[Rails.root + "db/bizible/services/*.txt"].each do |f|
#   category = File.basename(f, ".*").titlecase
#   File.readlines(f).each do |l|
#     Service.create(
#       name: l.strip,
#       category: category
#     )
#   end
# end

# feeds(\d)*.feedburner.com\/
service = Service.create(name: "FeedBurner")
Matcher.create(
  service: service,
  match_type: :regex,
  match_string: 'feeds(\d)*.feedburner.com\/'
)

service = Service.create(name: "Signal.co")
Matcher.create(
  service: service,
  match_type: :string,
  match_string: 's.btstatic.com/tag'
)

service = Service.create(name: "Signal.co")
Matcher.create(
  service: service,
  match_type: :string,
  match_string: 's.thebrighttag.com'
)

service = Service.create(name: "Sitecatalyst")
Matcher.create(
  service: service,
  match_type: :string,
  match_string: 'SiteCatalyst code'
)

service = Service.create(name: "Acquisio")
Matcher.create(
  service: service,
  match_type: :string,
  match_string: 'js.acq.io'
)

service = Service.create(name: "Ifbyphone")
Matcher.create(
  service: service,
  match_type: :string,
  match_string: 'secure.ifbyphone.com/js'
)

service = Service.create(name: "DaddyAnalytics")
Matcher.create(
  service: service,
  match_type: :string,
  match_string: 'cdn.daddyanalytics.com/w2/daddy.js'
)

service = Service.create(name: "Inside Social")
Matcher.create(
  service: service,
  match_type: :string,
  match_string: 'cdn1.insidesoci.al'
)

Matcher.create(
  service: service,
  match_type: :string,
  match_string: 'cdn.insidesocial.com'
)

service = Service.create(name: "Salesforce")
Matcher.create(
  service: service,
  match_type: :string,
  match_string: 'salesforce.com/servlet/servlet.WebToLead'
)

# # cbs
# Matcher.create(
#   service: Service.find_by_name("Optimizely"),
#   match_type: :regex,
#   match_string: "cdn.optimizely.com\/js\/([^.]+).js"
# )
#
# # adroll
# Matcher.create(
#   service: Service.find_by_name("Olark"),
#   match_type: :regex,
#   match_string: "olark.identify\(([^)]+)\)"
# )
#
#
# # optimizely, personal capital
# Matcher.create(
#   service: Service.find_by_name("Kissmetrics"),
#   match_type: :regex,
#   match_string: "i.kissmetrics.com\/i.js"
# )
#
# # NBC
# Matcher.create(
#   service: Service.find_by_name("Omniture"),
#   match_type: :regex,
#   match_string: '<a href="http:\/\/www.omniture.com" title="Web Analytics"><img src="\/([^.]+)" height="1" width="1" alt="" \/><\/a>'
# )
#
# # Traklight
# Matcher.create(
#   service: Service.find_by_name("Hubspot"),
#   match_type: :regex,
#   match_string: "https:\/\/js.hscta.net\/cta\/current.js"
# )
#
# # http://businessfactors.com/
# Matcher.create(
#   service: Service.find_by_name("LiveChat"),
#   match_type: :string,
#   match_string: "cdn.livechatinc.com"
# )
#
# Matcher.create(
#   service: Service.find_by_name("SnapEngage"),
#   match_type: :string,
#   match_string: "code.snapengage.com"
# )
#
# Matcher.create(
#   service: Service.find_by_name("Zopim"),
#   match_type: :string,
#   match_string: "window.$zopim"
# )
#
# Matcher.create(
#   service: Service.find_by_name("Google Tag Manager"),
#   match_type: :string,
#   match_string: "googletagmanager.com/gtm.js"
# )
#
# Matcher.create(
#   service: Service.find_by_name("Live Agent"),
#   match_type: :string,
#   match_string: "LiveAgentTracker."
# )
#
# # http://www.emimusicpub.com/
# Matcher.create(
#   service: Service.find_by_name("Marketo"),
#   match_type: :string,
#   match_string: "http://munchkin.marketo.net"
# )
#
# # from Pardot website http://www.pardot.com/faqs/campaigns/tracking-code/
# Matcher.create(
#   service: Service.find_by_name("Pardot"),
#   match_type: :string,
#   match_string: ".pardot.com/pd.js"
# )
#
# # https://www.hightail.com
# Matcher.create(
#   service: Service.find_by_name("Silverpop"),
#   match_type: :string,
#   match_string: "com.silverpop.brandeddomains"
# )
#
# # http://sitescout.com
# Matcher.create(
#   service: Service.find_by_name("Eloqua"),
#   match_type: :string,
#   match_string: "img.en25.com/i/elqCfg.min.js"
# )
#
# # https://www.kajabiapp.com
# Matcher.create(
#   service: Service.find_by_name("Snapengage"),
#   match_type: :string,
#   match_string: "code.snapengage.com/js"
# )
