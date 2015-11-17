class CocoapodServiceWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :scraper

	def perform(char, res_count, offset)

    scrape(char, res_count, offset)

  end

  def scrape(char, res_count, offset)

    ActiveRecord::Base.logger.level = 1

    base = "https://search.cocoapods.org/api/v1/pods.picky.hash.json"

    url = "#{base}?query=on%3Aios+#{char}&ids=#{res_count}&offset=#{offset}&sort=name"

    puts "Scraping #{char}, #{offset} - #{res_count.to_int + offset.to_int}"
    
    begin

      cocoapods = JSON.parse(Proxy.get(req: url).body).to_h

    rescue => e

      CocoapodException.create(name: "#{url}\n\n#{e.message}")

      raise

    else

      results = cocoapods['allocations']

      5.times do |i|

        next if results[i].nil?
      
        res = results[i][5]

        next if res.nil?

        res.each do |r|

          begin

            s = r['source']
            git = s['git']
            http = s['http']
            tag = s['tag']
            summ = r['summary']
            link = r['link']
            cdocs = r['cocoadocs']
            name = r['id']
            ver = r['version']

            cp = Cocoapod.create(git: git, http: http, tag: tag, summary: summ, link: link, cocoadocs: cdocs, name: name, version: ver)

            r['authors'].each do |name, email|

              CocoapodAuthor.find_or_create_by(name: name, email: email, cocoapod: cp)
            
            end

            r['tags'].each do |tag|

              CocoapodTag.create(tag: tag, cocoapod: cp)

            end

          rescue

            nil

          end
          
        end

      end

    end


  end

end