# Couldn't find a place where this class is called

# class FortuneRankService
#
#   class << self
#
#     def scrape
#       CSV.open("db/fortune/fortune1000-#{Time.now.year-1}.csv", "wb") do |csv|
#         csv << ['Name', 'Rank', 'Website']
#         10.times do |x|
#           response = HTTParty.get("http://fortune.com/api/v2/list/1666518/expand/item/ranking/asc/#{x*100}/100")
#           response = JSON.parse(response.body).with_indifferent_access
#           response['list-items'].each do |company|
#             website = company[:meta][:website]
#             rank = company[:rank]
#             name = company[:title]
#
#             domain = UrlHelper.url_with_domain_only(website.gsub('%20', ''))
#             puts "domain is #{domain}"
#             domain_datum = DomainDatum.find_or_create_by(domain: domain)
#             domain_datum.name ||= name
#
#             domain_datum.fortune_1000_rank = rank
#             domain_datum.save
#
#             csv << [name, rank, website]
#           end
#         end
#       end
#     end
#   end
#
#   def flag_domains
#     flags = {}
#     CSV.foreach('db/fortune/android-list.csv', :headers => true) do |row|
#       puts row[2]
#       if row[4].present?
#         if row[4] == 'x'
#           flags[row[2]] = []
#         else
#           test = [row[4].to_i]
#           test << row[5].to_i if row[5].to_i > 0
#           test << row[6].to_i if row[6].to_i > 0
#           test << row[7].to_i if row[7].to_i > 0
#           test << row[8].to_i if row[8].to_i > 0
#           flags[row[2]] = test
#         end
#       end
#     end
#     flags = flags.merge(ClearbitWorker::ANDROID_DEVELOPER_IDS){|key, oldval, newval|
#       (oldval += newval).uniq
#     }
#     ap flags
#   end
#
#   def generate_match_csv
#     results = {}
#     page = 1
#     while page < 11 do
#       filter_results = FilterService.filter_android_apps(company_filters: {'fortuneRank' => 1000}, page_num: page, page_size: 1000)
#       filter_results.each do |result|
#         publisher_name = result.attributes["publisher_name"]
#         fortune_rank = result.attributes["fortune_rank"]
#         domain_datum = DomainDatum.where(fortune_1000_rank: fortune_rank.to_i).first
#         fortune_company = domain_datum.name
#         fortune_domain = domain_datum.domain
#
#         results[publisher_name] = {
#                                     fortune_rank: fortune_rank,
#                                     fortune_company: fortune_company,
#                                     fortune_domain: fortune_domain,
#                                     publisher_name: publisher_name
#                                   }
#       end
#       page += 1
#     end
#
#     CSV.open("db/fortune/fortunematch-android-#{Time.now.year-1}.csv", "wb") do |csv|
#       csv << ['Fortune Company', 'Fortune Rank', 'Fortune Domain', 'Publisher Name']
#       results.each do |publisher_name, values|
#         csv << [values[:fortune_company], values[:fortune_rank], values[:fortune_domain], values[:publisher_name]]
#       end
#     end
#   end
# end
#
