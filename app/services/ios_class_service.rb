class IosClassService

	class << self

		def search

			class_dump = File.open('../Zinio.classdump.txt').read

			clss = class_dump.scan(/(@property|@protocol|@interface|struct|_Bool|\(void\)|\(id\)|\(int\))(.*?)\n/m)

			exclude_words = %w(ns ui categories table tab scroll search page library button zoom issue index image server theme purchase cl zinio)

			hash = Hash.new

			failed_terms = []
			
			successful_terms = []

			clss.each do |k, v|

				str = v[/[^<]+/].strip

				unless exclude_words.any?{ |s| str.downcase.include?(s) }

					str = str.gsub(/\((.*?)\)/m,'').gsub(/[^a-z0-9\s]/i,'').gsub('Bool','').gsub('Init','').gsub('init','').strip.split(' ').first

					next if str.blank?

					orig_str = str


				    words = str.gsub(/(message|binary|application|internal|custom|batch|through|viewed|view|event|for|thread|descriptor|unknown|save|login|delete|activity|key|logout|user|appears|hide|hidden|account|field|return|url|retry|handle|show|showing|controller|network|signin|request|background|display|submit|should|get|download|handle|change|ready|animate|animation|directory|object|portrait|landscape|toolbar|navigation|navbar|cancel|delay)/i,'')

				    words = words.split(/(?=[A-Z])/)

				    words_count = words.select{ |w| w.length > 1 }.count

				    words.pop if words_count >= 3

				    words.each.with_index do |word, index|

				      index = words.count - index

				      str = index.times.map do |i|

				        words[i]

				      end

				      str = str.join

				      if str.length >= 3

				        next if failed_terms.include?(str) || successful_terms.include?(str)

				        cocoapods = JSON.parse(open("https://search.cocoapods.org/api/v1/pods.picky.hash.json?query=on%3Aios+#{URI.escape(str)}&ids=20&offset=0&sort=quality").read).to_h

				        if cocoapods['allocations'].present?

				          pod = cocoapods['allocations'][0][5].select{|x| x['link'].present? && x['link'].exclude?('github.') }.sort_by{|x| x['id'].size }.first

				          if pod.present?

				            if str.similar(pod['id']) >= 80
				              puts str.green
				              puts "    => #{pod['id']}"
				              puts "    => #{pod['link']}"
				              puts "    => #{pod['source']}"
				              puts "    => #{orig_str}"

				              successful_terms << str
				              
				              break

				            else
				              puts str.yellow

				              failed_terms << str

				            end

				          else

				            pod = cocoapods['allocations'][0][5].sort_by{|x| x['id'].size }.first

				            return if pod['id'].blank?

				            if str.similar(pod['id']) >= 80
				              puts str.blue

				              successful_terms << str

				              File.open('../ios_sdk_companies.txt', 'wb') { |f| f.write successful_terms }

				            else
				              puts str.purple

				              failed_terms << str
				            end

				          end

				        else

				          puts str.red

				          failed_terms << str

				        end

				      end


				    end





				end

			end

			# hash.map do |k,v|

			# 	counts = Hash.new -1

			# 	v.each do |word|
			# 	  counts[word] += 1
			# 	end

			# 	{k => counts}

			# end

			nil

		end


	end

end