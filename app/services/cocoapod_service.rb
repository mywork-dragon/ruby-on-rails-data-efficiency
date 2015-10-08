class CocoapodService

	class << self

		def get_everything

			res_count = 100

			(0...36).map{ |i| i.to_s 36}.each do |char|

        total_res_count = CocoapodService.char_result_count(char)

        page_count = (total_res_count / res_count.to_f).ceil

				page_count.times do |i|

          offset = res_count * i

          CocoapodServiceWorker.new.perform(char, res_count, offset)
					
				end

			end

		end

    def char_result_count(char)

      cocoapods_url = "https://search.cocoapods.org/api/v1/pods.picky.hash.json"

      url = "#{cocoapods_url}?query=on%3Aios+#{char}&ids=0&offset=0&sort=name"

      results = JSON.parse(Proxy.get(req: url).body).to_h

      results['total']

    end

    def inspect_source

    	Cocoapod.all.each do |pod|

    		CocoapodServiceWorker.new.perform(pod.id)

    	end

    end

    def inspect_source_n(n = 100)

      Cocoapod.limit(n).each do |pod|

        CocoapodServiceWorker.new.perform(pod.id)

      end

    end

    # [8155,85,14088,14087]

    def inspect_source_by_ids(ids = [14])

    	ids.each do |id|

    		CocoapodServiceWorker.new.perform(id)

    	end

    end

    def apple_docs

      CocoapodSourceData.all.each do |d|

        CocoapodServiceWorker.new.in_apple_docs?(d.name)

      end

    end

	end

end