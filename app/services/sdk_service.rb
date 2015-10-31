class SdkService

	class << self

		def find(package:, platform:)
			query = query_from_package(package)
			url, company, kind = google_sdk(query: query, platform: platform) || google_github(query: query, platform: platform)
			{url: url, company: company, kind: kind}
		end


		# Extract company name from a package (ex. "com.facebook.activity" => "facebook")

		def query_from_package(package_name)
	    package = strip_prefix(package_name)
	    return nil if package.blank?
	    package = package.capitalize if package == package.upcase && package.count('.').zero?
	    first_word = package.split('.').first
	    first_word = g_words(first_word) if package.include? 'google'
	    name = camel_split(first_word)
	    return nil if name.nil? || name.length <= 1
	    name
		end

		# Get the url of an sdk if it is valid

		def google_sdk(query:, platform:)
			google_search(q: "#{query} #{platform} sdk", limit: 4).each do |url|
				ext = exts(:before).select{|s| url.include?(s) }.first
		    url = remove_sub(url).split(ext).first + ext
		    company = query.capitalize
				return url, company, :company if sdk_company_valid?(query: query, platform: platform, url: url, company: company)
			end
			nil
		end

		# Whether the SDK company is valid
		def sdk_company_valid?(query:, platform:, url:, company:)
						
			# Eliminate known companies
			known_companies = %w(
				Apple 
			)
			return false if known_companies.include?(company)

			return true if url.include?(query)

			false
		end

		# Get the url and company name of an sdk from github if it is valid

		def google_github(query:, platform:)
			google_search(q: "#{query} #{platform} site:github.com").each do |url|
				if !!(url =~ /https:\/\/github.com\/[a-z]*\/#{query}[^\/]*/i)
					company = url[/\/([^\/]+)(?=\/[^\/]+\/?\Z)/i,1]
					return url, company, :open_source
				end
			end
			nil
		end



		def google_search(q:, limit: 10)
		  result = Proxy.get(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q}, nokogiri: true)
		  result.search('cite').map{ |c| UrlHelper.http_with_url(c.inner_text) if valid_domain?(c.inner_text) }.compact.take(limit)
		end

		def valid_domain?(url)
			url.exclude?('...') && url != '0' && url.count('-') <= 1
		end

		def remove_sub(url)
			url.gsub(/(www|doc|docs|dev|developer|developers|cloud|support|help|documentation|dashboard|sdk|wiki)\./,'')
		end

		def exts(dot = nil)
			ext_file = File.open('exts.txt')
			ext_arr = ext_file.read.split(/\n/)
			ext_arr.map{|e| dot == :before ? ".#{e}" : (dot == :after ? "#{e}." : e)}
		end

		def strip_prefix(package)
	    package_arr = package.split(/\./)
	    prefix = package_arr.first
	    package_arr.shift if exts.include?(prefix) || prefix.blank?
	    package_arr.join('.')
		end

		def camel_split(str)
			str.split(/(?=[A-Z])/).map(&:capitalize).join(' ').strip
		end

		def g_words(str)
			words = %w(ads maps wallet analytics drive admob doubleclick plus)
			words.each{|g| str = 'google ' + g if package.include? g }
			str
		end

	end

end