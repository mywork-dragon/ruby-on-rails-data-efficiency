class SdkService

	QUERY_MINIMUM_LENGTH = 4
	DICE_SIMILARITY_THRESHOLD = 0.9

	class << self

		# @param packages: An Array of packages
		# @platform: :ios or :android
		def find_from_packages(packages:, platform:)
			sdks = []

			queries = []
			packages.each do |package|
				queries << query_from_package(package)
			end

			find_from_queries(queries: queries, platform: platform)
		end

		# Given the queries to search for, will find SDKs
		# When you already know what the queries will be
		# @author Jason Lew
		# @param The queries to run
		# @platform :ios or :android
		# @note Will only search unique queries
		def find_from_queries(queries:, platform:)
			queries = queries.uniq.compact
			
			return {} if queries.empty?

			sdks = []

			queries.each do |query|
				puts "Query: #{query}".green
				sdk = google_sdk(query: query, platform: platform) || google_github(query: query, platform: platform)
				ap sdk
				puts ""
				sdks << sdk if sdk
			end

			company_sdks = sdks.select{ |sdk| sdk[:kind] == :company}
			company_sdks.uniq!{ |x| [x[:company], x[:url]] }

			open_source_sdks = sdks.select{ |sdk| sdk[:kind] == :open_source}
			open_source_sdks.uniq{ |x| x[:repo_id]}

			company_sdks + open_source_sdks
		end

		def sdks_from_queries(queries:, platform:)

		end

		# Extract company name from a package (ex. "com.facebook.activity" => "facebook")
		# @author Jason Lew
		def query_from_package(package_name)
	    package = strip_prefix(package_name)
	    return nil if package.blank?
	    package = package.capitalize if package == package.upcase && package.count('.').zero?

	    name = if package.include? 'google'
	    	g_words(package)
	    else
	    	package.split('.').first
	    end

	    return nil if name.nil?
	    name = camel_split(name)

	    return nil if name.nil? || name.length < QUERY_MINIMUM_LENGTH # no good if it's nil or less than QUERY_MINIMUM_LENGTH

	    name
	    # first_word = package.split('.').first
	    # first_word = g_words(package) if package.include? 'google'
	    # return nil if first_word.nil?
	    # name = camel_split(first_word)
	    # return nil if name.nil? || name.length < QUERY_MINIMUM_LENGTH	# no good if it's nil or less than QUERY_MINIMUM_LENGTH
	    # name
		end

		# Get the url of an sdk if it is valid

		def google_sdk(query:, platform:)
			google_search(q: "#{query} #{platform} sdk", limit: 4).each do |url|
				puts "url: #{url}".yellow
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

			return true if UrlHelper.full_domain(url).downcase.include?(query.downcase)

			false
		end

		# Get the url and company name of an sdk from github if it is valid

		def google_github(query:, platform:)
			return nil unless github_query_valid?(query)

			q = "#{query} #{platform} site:github.com"
			google_search(q: q).each do |url|
				if !!(url =~ /https:\/\/github.com\/[^\/]*\/[^\/]*#{query}[^\/]*\z/i)	# if matches format like https://github.com/MightySignal/slackiq
					rd = GithubService.get_repo_data(url)
					next if rd['message'] == 'Not Found'	# repository is not valid; try the next link

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

					if repo_name = srd[:repo_name]
						dice_similarity = FuzzyMatch::Score::PureRuby.new(repo_name, query).dices_coefficient_similar
						next if dice_similarity < DICE_SIMILARITY_THRESHOLD	# query not similar enough to repo name
					end

					return {url: url, favicon: 'https://assets-cdn.github.com/favicon.ico', kind: :open_source}.merge(srd)
				end
			end
			nil
		end

		def github_query_valid?(query)
			query.downcase!

			invalid_queries = %w(
				apple
				queue
			)
			return false if invalid_queries.include?(query)

			true
		end

		def google_search(q:, limit: 10)
		  result = Proxy.get_nokogiri(req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q})
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