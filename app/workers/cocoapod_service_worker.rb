class CocoapodServiceWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :scraper

	def perform(char, res_count, offset)

    scrape(char, res_count, offset)

  end

  def scrape(char, res_count, offset)

    cocoapods_url = "https://search.cocoapods.org/api/v1/pods.picky.hash.json"

    url = "#{cocoapods_url}?query=on%3Aios+#{char}&ids=#{res_count}&offset=#{offset}&sort=name"
    
    begin

      cocoapods = JSON.parse(Proxy.get(req: url).body).to_h

    rescue => e

      CocoapodException.create(name: "#{url}\n\n#{e.message}")

      raise

    else

      results = cocoapods['allocations']

      5.times do |i|

        if results[i].present?
        
          res = results[i][5]

          if res.present?

            res.each do |result|

              begin

                cp = Cocoapod.create(git: result['source']['git'], http: result['source']['http'], tag: result['source']['tag'], summary: result['summary'], link: result['link'], cocoadocs: result['cocoadocs'], name: result['id'], version: result['version'])

                result['authors'].each do |name, email|

                  CocoapodAuthor.find_or_create_by(name: name, email: email, cocoapod: cp)
                
                end

                result['tags'].each do |tag|

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


  end

end