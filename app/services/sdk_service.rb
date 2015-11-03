class SdkService

	#TODO: filter out "Apple" query beforehand

	class << self

		# @param packages: An Array of packages
		# @platform: :ios or :android
		def find(packages:, platform:)
			sdks = []

			queries = []
			packages.each do |package|
				queries << query_from_package(package)
			end

			queries.uniq!
			queries.compact!

			return {} if queries.empty?

			queries.each do |query|
				sdk = google_sdk(query: query, platform: platform) || google_github(query: query, platform: platform)
				sdks << sdk if sdk
			end

			company_sdks = sdks.select{ |sdk| sdk[:kind] == :company}
			company_sdks.uniq!{ |x| [x[:company], x[:url]] }

			open_source_sdks = sdks.select{ |sdk| sdk[:kind] == :open_source}
			open_source_sdks.uniq{ |x| x[:repo_id]}

			company_sdks + open_source_sdks
		end

		# Extract company name from a package (ex. "com.facebook.activity" => "facebook")

		def query_from_package(package_name)
	    package = strip_prefix(package_name)
	    return nil if package.blank?
	    package = package.capitalize if package == package.upcase && package.count('.').zero?
	    first_word = package.split('.').first
	    first_word = g_words(first_word) if package.include? 'google'
	    return nil if first_word.nil?
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
				return {url: url, company: company, kind: :company} if sdk_company_valid?(query: query, platform: platform, url: url, company: company)
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

			return true if url.downcase.include?(query.downcase)

			false
		end

		# Get the url and company name of an sdk from github if it is valid

		def google_github(query:, platform:)
			return nil unless github_query_valid?(query)

			q = "#{query} #{platform} site:github.com"
			google_search(q: q).each do |url|
				if !!(url =~ /https:\/\/github.com\/[^\/]*\/[^\/]*#{query}[^\/]*\z/i)	#if matches format like https://github.com/MightySignal/slackiq
					rd = GithubService.get_repo_data(url)
					next if rd['message'] == 'Not Found'	#repository is not valid; try the next link

					#select repo data (srd) that we're interested in
					srd = {
						repo_id: rd['id'],
						repo_name: rd['name'],
						repo_description: rd['description'],
						repo_language: rd['language'],
						repo_owner_id: rd['owner']['id'],
						repo_owner_name: rd['owner']['login'],
						repo_owner_type: rd['owner']['type']
					}

					return {url: url, kind: :open_source}.merge(srd)
				end
			end
			nil
		end

		def github_query_valid?(query)
			query.downcase!

			invalid_queries = %w(
				apple
			)
			return false if invalid_queries.include?(query)

			true
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

		def g_words(package)
			words = %w(ads maps wallet analytics drive admob doubleclick plus)
			words.each do |g| 
				return 'google ' + g if package.include? g
			end
			nil
		end

	end

end