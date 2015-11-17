class SdkService

	class << self


		def validate_package(package:, platform:)
			query = name_from_package(package)
			known_name = known_sdks(query, package, platform)
			
			if known_name.nil?
				data = google_sdk(query: query, platform: platform) || google_github(query: query, platform: platform)
			else
				{'url'=>nil, 'name'=>known_name, 'type'=>:company}
			end

		end


		# Extract company name from a package (ex. "com.facebook.activity" => "facebook")

		def name_from_package(package_name)
	    package = strip_prefix(package_name)
	    return nil if package.blank?
	    package = package.capitalize if package == package.upcase && package.count('.').zero?
	    first_word = package.split('.').first
	    name = camel_split(first_word)
	    return nil if name.nil? || name.length <= 1
	    name
		end

		# Get the url of an sdk if it is valid

		def google_sdk(query:, platform:)
			google_search(q: "#{query} #{platform} sdk", limit: 4).each do |url|
				ext = exts(dot: :before).select{|s| url.include?(s) }.first
		    url = remove_sub(url).split(ext).first + ext
		    company = query
				return {'url'=>url, 'name'=>company, 'type'=>:company} if url.include?(query.downcase)
			end
			nil
		end

		# Get the url and company name of an sdk from github if it is valid

		def google_github(query:, platform:)
			google_search(q: "#{query} #{platform} site:github.com").each do |url|
				if !!(url =~ /https:\/\/github.com\/[a-z]*\/#{query}[^\/]*/i)
					company = camel_split(url[/\/([^\/]+)(?=\/[^\/]+\/?\Z)/i,1])
					return {'url'=>url, 'name'=>company, 'type'=>:open_source}
				end
			end
			nil
		end



		def google_search(q:, limit: 10)
		  result = Proxy.get_nokogiri(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q})
		  result.search('cite').map{ |c| UrlHelper.http_with_url(c.inner_text) if valid_domain?(c.inner_text) }.compact.take(limit)
		end

		def valid_domain?(url)
			url.exclude?('...') && url != '0' && url.count('-') <= 1
		end

		def remove_sub(url)
			sub_exts = File.open('sdk_configs/bad_url_prefixes.txt').read.gsub("\n","|")
			url.gsub(/(#{sub_exts})\./,'')
		end

		def exts(dot: nil, subs: false)
			ext_file = subs == true ? File.open('sdk_configs/bad_package_prefixes.txt') : File.open('sdk_configs/exts.txt')
			ext_arr = ext_file.read.split(/\n/)
			ext_arr.map{|e| dot == :before ? ".#{e}" : (dot == :after ? "#{e}." : e)}
		end

		def strip_prefix(package)
			package_name = strip(package, exts)
			strip(package_name, exts(subs: true))
		end

		def strip(package, extentions)
	    package_arr = package.split(/\./)
	    prefix = package_arr.first
	    package_arr.shift if extentions.include?(prefix) || prefix.blank?
	    package_arr.join('.')
		end

		def camel_split(str)
			str.split(/(?=[A-Z])/).map(&:capitalize).join(' ').strip
		end

		def known_sdks(name, package_name, platform)
			str = nil
			JSON.parse(File.open("sdk_configs/known_#{platform}_sdks.json").read).each do |sdk_name,sdk_types|
				if name == sdk_name
					sdk_types.each{|type| str = sdk_name + ' ' + type if !!(package_name =~ /#{type}/i) }
				end
			end
			str
		end

	end

end