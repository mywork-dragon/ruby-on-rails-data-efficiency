class FortuneRankService

  class << self

    def scrape
      CSV.open("db/fortune/fortune1000-#{Time.now.year-1}.csv", "wb") do |csv|
        csv << ['Name', 'Rank', 'Website']
        10.times do |x|  
          response = HTTParty.get("http://fortune.com/api/v2/list/1666518/expand/item/ranking/asc/#{x*100}/100")
          response = JSON.parse(response.body).with_indifferent_access
          response['list-items'].each do |company|
            website = company[:meta][:website]
            rank = company[:rank]
            name = company[:title]

            domain = UrlHelper.url_with_domain_only(website)
            domain_datum = DomainDatum.find_or_create_by(domain: domain)
            domain_datum.fortune_1000_rank = rank
            domain_datum.save

            csv << [name, rank, website]
          end
        end
      end
    end
  end
end