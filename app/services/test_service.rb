class TestService

	class << self

		def scan

			url = "http://tabs.ultimate-guitar.com/d/dan_auerbach/goin_home_ver4_tab.htm"

			doc = Proxy.get(req: url).body

			text = doc[/<pre>(.*)<\/pre>/m,1]

			capo = capo(text)

			tabs = "e|" + text[/e\|(.*)\|/m,1] + "|"

			string_hash = Hash.new

			tabs.split("\n").each do |line|

				if line.match(/(e|B|G|D|A|E)\|/)

					first_letter = line.slice(0)

					if string_hash[first_letter].blank?

						string_hash[first_letter] = [line]

					else

						string_hash[first_letter] << line

					end

				end

			end

			string_hash.each do |note, strings|

				puts "\n"

				puts note

				puts "\n"

				strings.each do |string|

					string.slice(0)

					string.split("|").each do |bar|

						bar = bar.split('').map{|n| n.to_i + capo unless n == '-' }

						ap bar

					end

				end

			end

		end

		def capo(text)

			text[/^.*?capo[^\d]*(\d+)[^\d]*\n.*$/i,1].to_i

		end

	end

end